# Returns Distribution Panel

- url: https://www.tradingview.com/script/bLpfXyBa/
- type: indicator
- pine_id: PUB;e808686f008042b7b263c22c9fa36d24
- version: 1.0

## Description

Rolling skewness, excess kurtosis (Fisher) and the Jarque-Bera test statistic of the return distribution over a configurable window, with a normal-at-95% flag against the chi-square critical value (5.99, 2 df). Highlights regimes where returns deviate materially from normality, such as fat tails or strong skew. It does NOT generate buy or sell signals.

What it shows
- Rolling skewness and excess kurtosis of log returns
- Jarque-Bera statistic and a YES/NO normality verdict at 95%

Honest by design
- No buy/sell signals. The YES/NO is a normality verdict, not a trade call.
- Non-repainting: rolling moments on confirmed bars.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Returns Distribution Panel
// Rolling skewness, kurtosis (Fisher excess) and Jarque-Bera test
// statistic for the return distribution over a configurable window.
// Highlights regimes where returns deviate materially from normality.
// Analytics panel only. Non-repainting, no signals.
indicator("Returns Distribution Panel", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

winLen = input.int(60, "Window length", minval = 8, group = "Window")

logRet = math.log(close / close[1])

mu = ta.sma(logRet, winLen)
m2 = ta.sma(math.pow(logRet - mu, 2), winLen)
m3 = ta.sma(math.pow(logRet - mu, 3), winLen)
m4 = ta.sma(math.pow(logRet - mu, 4), winLen)

sigma = math.sqrt(m2)
skew = sigma > 0 ? m3 / math.pow(sigma, 3) : na
exKurt = m2 > 0 ? m4 / math.pow(m2, 2) - 3.0 : na

jb = winLen * (math.pow(nz(skew), 2) / 6.0 + math.pow(nz(exKurt), 2) / 24.0)

plot(skew, title = "Skewness", color = color.new(color.aqua, 0))
plot(exKurt, title = "Excess kurtosis", color = color.new(color.orange, 0))
plot(jb, title = "Jarque-Bera", color = color.new(color.fuchsia, 30))
hline(0, title = "zero", color = color.new(color.gray, 50),
     linestyle = hline.style_dashed)
hline(5.99, title = "JB 95% chi2",
     color = color.new(color.gray, 30), linestyle = hline.style_dotted)

var table t = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Returns Distribution",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Skewness")
    table.cell(t, 1, 1, na(skew) ? "na" : str.tostring(skew, "#.###"))
    table.cell(t, 0, 2, "Excess kurtosis")
    table.cell(t, 1, 2, na(exKurt) ? "na" : str.tostring(exKurt, "#.###"))
    table.cell(t, 0, 3, "Jarque-Bera")
    table.cell(t, 1, 3, na(jb) ? "na" : str.tostring(jb, "#.##"))
    table.cell(t, 0, 4, "Normal at 95%?")
    table.cell(t, 1, 4, jb < 5.99 ? "YES" : "NO",
         bgcolor = jb < 5.99 ? color.new(color.green, 30) :
              color.new(color.orange, 30),
         text_color = color.white)
````
