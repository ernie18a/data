<!-- tradingview-pine-id: PUB;ed261fec20be4535a9c0c204f6543a27 -->
<!-- tradingviewscripts-format: 1 -->
# Bloomberg Financial Conditions Index (Proxy)

Source: https://www.tradingview.com/script/EktpAXcq-Bloomberg-Financial-Conditions-Index-Proxy/

## Description

The Bloomberg Financial Conditions Index (BFCI): A Proxy Implementation

Financial conditions indices (FCIs) have become essential tools for economists, policymakers, and market participants seeking to quantify and monitor the overall state of financial markets. Among these measures, the Bloomberg Financial Conditions Index (BFCI) has emerged as a particularly influential metric. Originally developed by Bloomberg L.P., the BFCI provides a comprehensive assessment of stress or ease in financial markets by aggregating various market-based indicators into a single, standardized value (Hatzius et al., 2010).

The original Bloomberg Financial Conditions Index synthesizes approximately 50 different financial market variables, including money market indicators, bond market spreads, equity market valuations, and volatility measures. These variables are normalized using a Z-score methodology, weighted according to their relative importance to overall financial conditions, and then aggregated to produce a composite index (Carlson et al., 2014). The resulting measure is centered around zero, with positive values indicating accommodative financial conditions and negative values representing tighter conditions relative to historical norms.
As Angelopoulou et al. (2014) note, financial conditions indices like the BFCI serve as forward-looking indicators that can signal potential economic developments before they manifest in traditional macroeconomic data. Research by Adrian et al. (2019) demonstrates that deteriorating financial conditions, as measured by indices such as the BFCI, often precede economic downturns by several months, making these indices valuable tools for predicting changes in economic activity.

Proxy Implementation Approach

The implementation presented in this Pine Script indicator represents a proxy of the original Bloomberg Financial Conditions Index, attempting to capture its essential features while acknowledging several significant constraints. Most critically, while the original BFCI incorporates approximately 50 financial variables, this proxy version utilizes only six key market components due to data accessibility limitations within the TradingView platform. 

These components include:

[*]
Equity market performance (using SPY as a proxy for S&P 500)

[*]
Bond market yields (using TLT as a proxy for 20+ year Treasury yields)

[*]
Credit spreads (using the ratio between LQD and HYG as a proxy for investment-grade to high-yield spreads)

[*]
Market volatility (using VIX directly)

[*]
Short-term liquidity conditions (using SHY relative to equity prices as a proxy)

Each component is transformed into a Z-score based on log returns, weighted according to approximated importance (with weights derived from literature on financial conditions indices by Brave and Butters, 2011), and aggregated into a composite measure.

Differences from the Original BFCI

The methodology employed in this proxy differs from the original BFCI in several important ways. First, the variable selection is necessarily limited compared to Bloomberg's comprehensive approach. Second, the proxy relies on ETFs and publicly available indices rather than direct market rates and spreads used in the original. Third, the weighting scheme, while informed by academic literature, is simplified compared to Bloomberg's proprietary methodology, which may employ more sophisticated statistical techniques such as principal component analysis (Kliesen et al., 2012).

These differences mean that while the proxy BFCI captures the general direction and magnitude of financial conditions, it may not perfectly replicate the precision or sensitivity of the original index. As Aramonte et al. (2013) suggest, simplified proxies of financial conditions indices typically capture broad movements in financial conditions but may miss nuanced shifts in specific market segments that more comprehensive indices detect.

Practical Applications and Limitations

Despite these limitations, research by Arregui et al. (2018) indicates that even simplified financial conditions indices constructed from a limited set of variables can provide valuable signals about market stress and future economic activity. The proxy BFCI implemented here still offers significant insight into the relative ease or tightness of financial conditions, particularly during periods of market stress when correlations among financial variables tend to increase (Rey, 2015).

In practical applications, users should interpret this proxy BFCI as a directional indicator rather than an exact replication of Bloomberg's proprietary index. When the index moves substantially into negative territory, it suggests deteriorating financial conditions that may precede economic weakness. Conversely, strongly positive readings indicate unusually accommodative financial conditions that might support economic expansion but potentially also signal excessive risk-taking behavior in markets (López-Salido et al., 2017).

The visual implementation employs a color gradient system that enhances interpretation, with blue representing neutral conditions, green indicating accommodative conditions, and red signaling tightening conditions—a design choice informed by research on optimal data visualization in financial contexts (Few, 2009).

References

Adrian, T., Boyarchenko, N. and Giannone, D. (2019) 'Vulnerable Growth', American Economic Review, 109(4), pp. 1263-1289.

Angelopoulou, E., Balfoussia, H. and Gibson, H. (2014) 'Building a financial conditions index for the euro area and selected euro area countries: what does it tell us about the crisis?', Economic Modelling, 38, pp. 392-403.

Aramonte, S., Rosen, S. and Schindler, J. (2013) 'Assessing and Combining Financial Conditions Indexes', Finance and Economics Discussion Series, Federal Reserve Board, Washington, D.C.

Arregui, N., Elekdag, S., Gelos, G., Lafarguette, R. and Seneviratne, D. (2018) 'Can Countries Manage Their Financial Conditions Amid Globalization?', IMF Working Paper No. 18/15.

Brave, S. and Butters, R. (2011) 'Monitoring financial stability: A financial conditions index approach', Economic Perspectives, Federal Reserve Bank of Chicago, 35(1), pp. 22-43.

Carlson, M., Lewis, K. and Nelson, W. (2014) 'Using policy intervention to identify financial stress', International Journal of Finance & Economics, 19(1), pp. 59-72.

Few, S. (2009) Now You See It: Simple Visualization Techniques for Quantitative Analysis. Analytics Press, Oakland, CA.

Hatzius, J., Hooper, P., Mishkin, F., Schoenholtz, K. and Watson, M. (2010) 'Financial Conditions Indexes: A Fresh Look after the Financial Crisis', NBER Working Paper No. 16150.

Kliesen, K., Owyang, M. and Vermann, E. (2012) 'Disentangling Diverse Measures: A Survey of Financial Stress Indexes', Federal Reserve Bank of St. Louis Review, 94(5), pp. 369-397.

López-Salido, D., Stein, J. and Zakrajšek, E. (2017) 'Credit-Market Sentiment and the Business Cycle', The Quarterly Journal of Economics, 132(3), pp. 1373-1426.

Rey, H. (2015) 'Dilemma not Trilemma: The Global Financial Cycle and Monetary Policy Independence', NBER Working Paper No. 21162.

---

## Source Code

````pine
//@version=6
indicator("Bloomberg Financial Conditions Index (Proxy)", shorttitle="BFCI", overlay=false)

// === Inputs ===
lookback    = input.int(252, "Z-Score Lookback (Days)", minval=50)
smoothing   = input.int(10, "Smoothing", minval=1)
use_glow    = input.bool(true, "Enable Glow Effect")
show_comps  = input.bool(false, "Show Components")

// === Symbols ===
ticker_eq   = "SPY"     // Equity Market: S&P 500 ETF
ticker_gov  = "TLT"     // Bond Market: 20+ Year Treasury ETF
ticker_hy   = "HYG"     // High-Yield Corporate Bonds
ticker_ig   = "LQD"     // Investment-Grade Corporate Bonds
ticker_vix  = "VIX"     // Market Volatility
ticker_cash = "SHY"     // Short-Term Treasuries (for interest rate component)

// === Weights ===
w_eq   = 0.25  // Equity weight
w_gov  = 0.20  // Government bonds weight
w_cs   = 0.25  // Credit spread weight
w_vol  = 0.20  // Volatility weight
w_liq  = 0.10  // Liquidity weight

// === Helper: Z-Score Calculation ===
zscore(src, len) =>
    lr = math.log(src / src[1])
    mean = ta.sma(lr, len)
    std  = ta.stdev(lr, len)
    (lr - mean) / std

// === Components ===
eq_price   = request.security(ticker_eq, timeframe.period, close)
gov_price  = request.security(ticker_gov, timeframe.period, close)
hy_price   = request.security(ticker_hy, timeframe.period, close)
ig_price   = request.security(ticker_ig, timeframe.period, close)
vix_price  = request.security(ticker_vix, timeframe.period, close)
cash_price = request.security(ticker_cash, timeframe.period, close)

// === Z-Scores ===
eq_z = zscore(eq_price, lookback)
gov_z = -zscore(gov_price, lookback)  // Inverted, as falling bond prices mean higher yields
spread_ratio = ig_price / hy_price    // Credit spread proxy
cs_z = -zscore(spread_ratio, lookback)  // Inverted, as tighter spreads mean better conditions
vol_z = -zscore(vix_price, lookback)  // Inverted, as lower volatility means better conditions
liq_ratio = cash_price / eq_price     // Liquidity/interest rate proxy
liq_z = -zscore(liq_ratio, lookback)  // Inverted, as lower ratio indicates better conditions

// === Total Index ===
raw_fci = eq_z * w_eq + gov_z * w_gov + cs_z * w_cs + vol_z * w_vol + liq_z * w_liq
fci = ta.sma(raw_fci, smoothing)

// === Traditional TradingView Colors ===
// Using standard TradingView color scheme
neutral_color = color.new(#2196F3, 0)  // TradingView blue
bull_color = color.new(#4CAF50, 0)     // TradingView green
bear_color = color.new(#FF5252, 0)     // TradingView red

// Dynamic color based on financial conditions
fci_color = fci >= 1.0 ? bull_color : 
           fci <= -1.0 ? bear_color : 
           fci > 0 ? color.from_gradient(fci, 0, 1, neutral_color, bull_color) :
           color.from_gradient(fci, -1, 0, bear_color, neutral_color)

// Dynamic background color with higher transparency
bg_neutral = color.new(#2196F3, 90)  // Almost transparent blue
bg_bull = color.new(#4CAF50, 75)     // Semi-transparent green
bg_bear = color.new(#FF5252, 75)     // Semi-transparent red

// Continuous dynamic background color
bg_color = fci >= 1.0 ? 
           color.from_gradient(math.min(fci, 2), 1, 2, bg_bull, color.new(#4CAF50, 85)) : 
           fci <= -1.0 ? 
           color.from_gradient(math.max(fci, -2), -2, -1, color.new(#FF5252, 85), bg_bear) :
           fci > 0 ? 
           color.from_gradient(fci, 0, 1, bg_neutral, bg_bull) :
           color.from_gradient(fci, -1, 0, bg_bear, bg_neutral)

bgcolor(bg_color)

// === Reference Lines ===
hline(0, "Neutral", color=color.gray, linestyle=hline.style_dashed)
hline(1, "Loose Conditions", color=color.green, linestyle=hline.style_dotted)
hline(-1, "Tight Conditions", color=color.red, linestyle=hline.style_dotted)

// === Plots ===
plot(fci, title="BFCI", color=fci_color, linewidth=2)
plot(use_glow ? fci : na, title="Glow Inner", color=color.new(fci_color, 75), linewidth=4)
plot(use_glow ? fci : na, title="Glow Outer", color=color.new(fci_color, 90), linewidth=6)

// === Component Plots ===
disp = show_comps ? display.all : display.none
plot(eq_z * w_eq, "Equity", color=color.green, display=disp, linewidth=1)
plot(gov_z * w_gov, "Bonds", color=color.orange, display=disp, linewidth=1)
plot(cs_z * w_cs, "Credit", color=color.purple, display=disp, linewidth=1)
plot(vol_z * w_vol, "Volatility", color=color.red, display=disp, linewidth=1)
plot(liq_z * w_liq, "Liquidity", color=color.teal, display=disp, linewidth=1)

// === Component Table ===
if barstate.islast
    var table t = table.new(position.top_right, 2, 6, frame_color=color.gray, 
                             frame_width=1, border_width=1, 
                             bgcolor=color.new(color.black, 85))
    
    // Headers
    table.cell(t, 0, 0, "Component", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 0, "Z-Score", text_color=color.white, text_size=size.small)
    
    // Equity row
    table.cell(t, 0, 1, "Equity", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(eq_z, "#.##"), 
              text_color=eq_z > 0 ? color.green : color.red, text_size=size.small)
    
    // Treasury row
    table.cell(t, 0, 2, "Treasury", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(gov_z, "#.##"), 
              text_color=gov_z > 0 ? color.green : color.red, text_size=size.small)
    
    // Credit row
    table.cell(t, 0, 3, "Credit Spread", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(cs_z, "#.##"), 
              text_color=cs_z > 0 ? color.green : color.red, text_size=size.small)
    
    // Volatility row
    table.cell(t, 0, 4, "Volatility", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 4, str.tostring(vol_z, "#.##"), 
              text_color=vol_z > 0 ? color.green : color.red, text_size=size.small)
    
    // Liquidity row
    table.cell(t, 0, 5, "Liquidity", text_color=color.white, text_size=size.small)
    table.cell(t, 1, 5, str.tostring(liq_z, "#.##"), 
              text_color=liq_z > 0 ? color.green : color.red, text_size=size.small)
````
