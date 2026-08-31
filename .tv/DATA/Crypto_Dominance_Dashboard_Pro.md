<!-- tradingview-pine-id: PUB;017de68b5d034402a449be6a8e540b41 -->
<!-- tradingviewscripts-format: 1 -->
# Crypto Dominance Dashboard Pro

Source: https://www.tradingview.com/script/qgn2PGA7-TCP-Dominance-Dashboard-Crypto-Version/

## Description

🚀 Crypto Dominance Dashboard Pro
A Complete Dashboard for Monitoring Crypto Market Rotation

Understanding where capital is moving within the cryptocurrency market is one of the most valuable insights for traders and investors.

The crypto market is constantly shifting between Bitcoin, large-cap altcoins, small-cap assets, and stablecoins. Monitoring these rotations manually often requires multiple charts and significant analysis.

Crypto Dominance Dashboard Pro simplifies this process by bringing together the most important dominance metrics, market capitalization indexes, trend analysis, and momentum data into a single, easy-to-read dashboard.

Instead of switching between several charts, you can monitor the overall market structure, evaluate capital rotation, and gain a clearer view of the current market environment from one place.

Whether you're analyzing short-term market movements or following longer-term trends, the dashboard is designed to provide objective market context that can support your own trading and investment decisions.

✨ Features
📊 Comprehensive Market Dashboard

Track the most important crypto market metrics in real time:

• 🟠 Bitcoin (BTC)

• 🔵 Ethereum (ETH)

• 🟡 Bitcoin Dominance (BTC.D)

• 🟣 Ethereum Dominance (ETH.D)

• 🟢 Tether Dominance (USDT.D)

• ⚪ OTHERS Dominance

• 🌍 TOTAL Market Capitalization

• 🌎 TOTAL2 Market Capitalization

• 🌏 TOTAL3 Market Capitalization

• ⚡ ETH/BTC Relative Strength

🔄 Smart Market Regime Detection

The dashboard continuously evaluates multiple market conditions to identify the current market environment.

Possible market regimes include:

🟠 Bullish Bitcoin Environment

🔵 Bullish Large-Cap Altcoin Environment

🟢 Bullish Small-Cap Altcoin Environment

🔴 Bearish Bitcoin Environment

🔴 Bearish Large-Cap Altcoin Environment

⚪ Neutral / Range Market

Each regime is determined using a combination of dominance metrics, trend analysis, momentum, and capital rotation instead of relying on a single indicator.

📈 Trend Analysis

Monitor trend direction across key market metrics using moving average analysis.

Included trend detection:

✅ Bitcoin Price

✅ Bitcoin Dominance

✅ OTHERS Dominance

✅ Total Crypto Market

⚡ Momentum Analysis

The dashboard measures momentum across multiple market indexes to provide additional context for market activity.

Percentage change calculations include:

📈 BTC

📈 ETH

📈 BTC.D

📈 ETH.D

📈 USDT.D

📈 OTHERS.D

📈 TOTAL

📈 TOTAL2

📈 TOTAL3

📈 ETH/BTC

This approach helps traders monitor how strength and weakness develop across different areas of the market.

⏱ Automatic Timeframe Adaptation

Market conditions can look very different across timeframes.

To improve consistency, the indicator automatically adjusts its internal thresholds based on the selected chart timeframe.

Supported across:

⏱ 5 Minutes

⏱ 15 Minutes

⏱ 1 Hour

⏱ 4 Hours

⏱ Daily

⏱ Weekly

This adaptive scaling allows the dashboard to remain responsive across multiple trading styles.

💡 Market Outlook

Based on the detected market regime, the dashboard provides an easy-to-read market outlook to help interpret current conditions.

Examples include:

🟠 Bitcoin Leading the Market

🔵 Strength in Large-Cap Altcoins

🟢 Improving Small-Cap Participation

🔴 Defensive / Risk-Off Conditions

⚪ Neutral Market Structure

These summaries are intended to provide additional context and should be considered alongside your own market analysis.

🔔 Built-in Alerts

Receive TradingView alerts whenever significant market conditions change.

Available alerts include:

✅ Bullish Bitcoin Environment

✅ Bullish Large-Cap Altcoin Environment

✅ Bullish Small-Cap Altcoin Environment

✅ Bearish Bitcoin Environment

✅ Bearish Large-Cap Altcoin Environment

✅ Risk-Off Conditions

Alerts help you stay informed about important market changes without continuously monitoring every chart.

🎨 Clean & Informative Interface

The dashboard is designed to present a large amount of market information in a clear and organized format.

✔ Color-coded momentum

✔ Trend direction indicators

✔ Percentage change tracking

✔ Market regime overview

✔ Market outlook summary

✔ Automatic timeframe scaling

Everything is organized to provide quick access to the information that matters most.

👥 Who Is This Indicator For?

Crypto Dominance Dashboard Pro is suitable for:

📌 Day Traders

📌 Swing Traders

📌 Position Traders

📌 Scalpers

📌 Long-Term Investors

📌 Portfolio Managers

📌 Market Analysts

Anyone interested in monitoring market structure and capital rotation can benefit from this dashboard.

🎯 Why Use Crypto Dominance Dashboard Pro?

Price is only one part of the market.

Dominance metrics, market capitalization indexes, relative strength, momentum, and trend analysis each provide a different perspective on market behavior.

By bringing these elements together into one dashboard, Crypto Dominance Dashboard Pro helps traders monitor changing market conditions, understand capital rotation, and build additional context for their own analysis.

Rather than focusing on a single metric, the dashboard provides a broader view of the crypto market that can support more informed decision-making.

⚠️ Disclaimer

This indicator is designed for educational and analytical purposes only.

It is intended to provide market context based on publicly available market data and should not be interpreted as financial or investment advice.

Always perform your own research and risk management before making trading or investment decisions.

❤️ Support the Project

If you find this indicator useful, your support is greatly appreciated.

⭐ Add it to your Favorites

👍 Like the script

💬 Leave a review and share your feedback

📢 Share it with other traders who may find it useful

Your feedback helps improve future updates and supports the development of additional tools for the TradingView community.

Thank you for your support, and happy trading! 🚀

This indicator was designed and developed by TradeCityPro.

Special thanks to the TradeCityPro community for their continuous support, valuable feedback, and contribution to improving this project.

Thank you for your support, and happy trading! 🚀

---

## Source Code

````pine
//@version=6
indicator("Crypto Dominance Dashboard Pro", overlay=true)

// ====== INPUTS ======
fastLen  = input.int(9,  "Fast MA",  group="Moving Averages")
slowLen  = input.int(21, "Slow MA",  group="Moving Averages")
lookback = input.int(14, "Momentum Lookback (bars)", group="Moving Averages")

autoScale = input.bool(true, "Auto-scale thresholds by timeframe", group="Thresholds")

usdtUpTh    = input.float(1.5, "USDT.D pump threshold %  (daily base)", group="Thresholds")
btcDTh      = input.float(1.0, "BTC.D trend threshold %  (daily base)", group="Thresholds")
othTh       = input.float(2.0, "OTHERS.D threshold %     (daily base)", group="Thresholds")
priceDumpTh = input.float(3.0, "Price dump threshold %   (daily base)", group="Thresholds")

tblPos   = input.string("top_right", "Table Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group="Display")
tblSize  = input.string("normal",    "Table Size",     options=["tiny","small","normal","large"], group="Display")

// ====== TIMEFRAME SCALING ======
// Scale factor based on current timeframe vs daily baseline
tfMinutes = timeframe.in_seconds(timeframe.period) / 60.0
dailyMinutes = 1440.0
tfScale = autoScale ? math.sqrt(tfMinutes / dailyMinutes) : 1.0

usdtUpTh_scaled    = usdtUpTh * tfScale
btcDTh_scaled      = btcDTh * tfScale
othTh_scaled       = othTh * tfScale
priceDumpTh_scaled = priceDumpTh * tfScale

// ====== DATA ======
f_sec(sym) => request.security(sym, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)

btcPrice = f_sec("BINANCE:BTCUSDT")
ethPrice = f_sec("BINANCE:ETHUSDT")
btcD     = f_sec("CRYPTOCAP:BTC.D")
ethD     = f_sec("CRYPTOCAP:ETH.D")
usdtD    = f_sec("CRYPTOCAP:USDT.D")
othersD  = f_sec("CRYPTOCAP:OTHERS.D")
total    = f_sec("CRYPTOCAP:TOTAL")
total2   = f_sec("CRYPTOCAP:TOTAL2")
total3   = f_sec("CRYPTOCAP:TOTAL3")
ethBtc   = f_sec("BINANCE:ETHBTC")

// ====== MOMENTUM ======
f_chg(src) => (src - src[lookback]) / src[lookback] * 100

btc_chg     = f_chg(btcPrice)
eth_chg     = f_chg(ethPrice)
btcD_chg    = f_chg(btcD)
ethD_chg    = f_chg(ethD)
usdtD_chg   = f_chg(usdtD)
othersD_chg = f_chg(othersD)
total_chg   = f_chg(total)
total2_chg  = f_chg(total2)
total3_chg  = f_chg(total3)
ethBtc_chg  = f_chg(ethBtc)

// ====== TRENDS ======
f_trend(src) =>
    fast = ta.sma(src, fastLen)
    slow = ta.sma(src, slowLen)
    fast > slow ? 1 : fast < slow ? -1 : 0

btcD_t    = f_trend(btcD)
total_t   = f_trend(total)
othersD_t = f_trend(othersD)
btc_t     = f_trend(btcPrice)

// ====== REGIME LOGIC ======
shortLowCaps = usdtD_chg >= usdtUpTh_scaled and total3_chg < total2_chg and total_chg < 0 and othersD_chg < 0
shortAlts    = btc_t == -1 and btcD_t == 1 and total2_chg < total_chg and ethBtc_chg < 0 and total2_chg < -priceDumpTh_scaled
shortBTC     = btc_t == -1 and btc_chg < -priceDumpTh_scaled and total_chg < 0 and not shortLowCaps and not shortAlts

btcSeason      = not shortBTC and not shortAlts and not shortLowCaps and btc_t == 1 and btcD_t == 1 and total_t == 1 and btcD_chg > btcDTh_scaled
top10Season    = not shortBTC and not shortAlts and not shortLowCaps and btc_t == 1 and btcD_t == -1 and total2_chg > total_chg and ethBtc_chg > 0 and total_chg > 0
altSeasonSmall = not shortBTC and not shortAlts and not shortLowCaps and btcD_t == -1 and othersD_t == 1 and othersD_chg > othTh_scaled and total3_chg > total2_chg

regimeTxt = shortLowCaps ? "[SHORT] LOW CAPS / OTHERS" : shortAlts ? "[SHORT] TOP 10 ALTS" : shortBTC ? "[SHORT] BTC" : btcSeason ? "[LONG] BTC" : top10Season ? "[LONG] TOP 10 ALTS" : altSeasonSmall ? "[LONG] LOW CAPS" : "[WAIT] NEUTRAL / RANGE"

regimeBg = shortLowCaps ? color.new(color.maroon, 0) : shortAlts ? color.new(color.red, 0) : shortBTC ? color.new(color.red, 30) : btcSeason ? color.new(color.orange, 0) : top10Season ? color.new(color.blue, 0) : altSeasonSmall ? color.new(color.green, 0) : color.new(color.gray, 20)

suggestion = shortLowCaps ? "Short OTHERS / low caps, tight SL" : shortAlts ? "Short alts, ETHBTC short pairs" : shortBTC ? "Short BTC, low leverage only" : btcSeason ? "Long BTC, avoid alts" : top10Season ? "Long ETH and top 10 alts" : altSeasonSmall ? "Long small caps, risky but high R" : "Stay flat, wait for setup"

// ====== HELPERS ======
f_arrow(x) => x > 0 ? "UP" : x < 0 ? "DN" : "--"
f_col(x)   => x > 0 ? color.new(color.green, 0) : x < 0 ? color.new(color.red, 0) : color.new(color.gray, 20)

posMap(p)  => p == "top_left" ? position.top_left : p == "top_right" ? position.top_right : p == "bottom_left" ? position.bottom_left : p == "bottom_right" ? position.bottom_right : p == "middle_left" ? position.middle_left : position.middle_right
sizeMap(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : size.normal

// ====== TABLE ======
var table tbl = table.new(posMap(tblPos), 3, 17, border_width=1, border_color=color.new(color.gray, 50))

f_row(row, label, val, chg, invert) =>
    table.cell(tbl, 0, row, label, text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 1, row, val,   text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 2, row, f_arrow(chg) + " " + str.tostring(chg, "#.##") + "%", bgcolor=f_col(invert ? -chg : chg), text_color=color.white, text_size=sizeMap(tblSize))

if barstate.islast
    table.cell(tbl, 0, 0, "Asset",    bgcolor=color.new(color.blue, 50), text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 1, 0, "Value",    bgcolor=color.new(color.blue, 50), text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 2, 0, "Change %", bgcolor=color.new(color.blue, 50), text_color=color.white, text_size=sizeMap(tblSize))

    f_row(1, "BTC",      "$" + str.tostring(btcPrice, "#,###"), btc_chg, false)
    f_row(2, "ETH",      "$" + str.tostring(ethPrice, "#,###"), eth_chg, false)
    f_row(3, "BTC.D",    str.tostring(btcD,    "#.##") + "%", btcD_chg,    false)
    f_row(4, "ETH.D",    str.tostring(ethD,    "#.##") + "%", ethD_chg,    false)
    f_row(5, "USDT.D",   str.tostring(usdtD,   "#.##") + "%", usdtD_chg,   true)
    f_row(6, "OTHERS.D", str.tostring(othersD, "#.##") + "%", othersD_chg, false)
    f_row(7, "TOTAL",    str.tostring(total/1e12,  "#.##") + "T", total_chg,  false)
    f_row(8, "TOTAL2",   str.tostring(total2/1e12, "#.##") + "T", total2_chg, false)
    f_row(9, "TOTAL3",   str.tostring(total3/1e12, "#.##") + "T", total3_chg, false)
    f_row(10, "ETH/BTC", str.tostring(ethBtc, "#.#####"),        ethBtc_chg, false)

    // TF scale info
    table.cell(tbl, 0, 12, "TF Scale", bgcolor=color.new(color.purple, 30), text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 1, 12, str.tostring(tfScale, "#.##") + "x", bgcolor=color.new(color.purple, 30), text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 2, 12, "USDT:" + str.tostring(usdtUpTh_scaled, "#.##") + "%", bgcolor=color.new(color.purple, 30), text_color=color.white, text_size=sizeMap(tblSize))

    table.cell(tbl, 0, 14, "REGIME",    bgcolor=color.new(color.black, 0), text_color=color.yellow, text_size=sizeMap(tblSize))
    table.cell(tbl, 1, 14, regimeTxt,   bgcolor=regimeBg, text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 2, 14, "",          bgcolor=regimeBg)

    table.cell(tbl, 0, 15, "ACTION",    bgcolor=color.new(color.black, 0), text_color=color.yellow, text_size=sizeMap(tblSize))
    table.cell(tbl, 1, 15, suggestion,  bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=sizeMap(tblSize))
    table.cell(tbl, 2, 15, "",          bgcolor=color.new(color.gray, 40))

// ====== ALERTS ======
alertcondition(shortLowCaps,   "Short Low Caps", "Low caps bleeding - short OTHERS")
alertcondition(shortAlts,      "Short Alts",     "Top 10 alts bleeding to BTC - short alts")
alertcondition(shortBTC,       "Short BTC",      "BTC in downtrend - consider short")
alertcondition(btcSeason,      "Long BTC",       "BTC dominance + price rising")
alertcondition(top10Season,    "Long Top 10",    "Capital rotating to top 10 alts")
alertcondition(altSeasonSmall, "Long Low Caps",  "Alt season - low caps pumping")
````
