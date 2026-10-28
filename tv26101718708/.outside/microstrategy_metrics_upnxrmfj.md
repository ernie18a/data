# MicroStrategy Metrics

- url: https://www.tradingview.com/script/uPnxRmFJ-MicroStrategy-Metrics/
- type: indicator
- pine_id: PUB;a15a81fcba1e4239a49490d60e68e6fb
- version: 35.0

## Description

A script showing all the key MSTR metrics. I will update the script every time degen Saylor sells some more office furniture to buy BTC. 

All based around valuing MSTR, aside from its BTC holdings. I.e. the true market cap = enterprise value - BTC holdings. Hence, you're left with the value of the software business + any premium/discount decided by investors.

From this we can derive:
- BTC Holdings % of enterprise value
- Correlation to BTC (in this case we use CME futures...may change this)
- Equivalent Share Price (true market cap divided by shares outstanding)
- P/E Ratio (equivalent share price divided by quarterly EPS estimates x 4)
- Price to FCF Ratio (true market cap divided by FCF (ttm))
- Price to Revenue (^ but with total revenue (ttm))

## Source Code

````pine
//@version=6
indicator('MicroStrategy Metrics', shorttitle = 'MSTR Metrics')

// MSTR BTC Data Array
var btc_dates = array.new_int(0)
var btc_cumulatives = array.new_int(0)

if barstate.isfirst
    array.push(btc_dates, timestamp(syminfo.timezone, 2020, 08, 11, 0, 0))
    array.push(btc_cumulatives, 21454)

    array.push(btc_dates, timestamp(syminfo.timezone, 2020, 09, 14, 0, 0))
    array.push(btc_cumulatives, 38250)

    array.push(btc_dates, timestamp(syminfo.timezone, 2020, 12, 5, 0, 0))
    array.push(btc_cumulatives, 40824)

    array.push(btc_dates, timestamp(syminfo.timezone, 2020, 12, 21, 0, 0))
    array.push(btc_cumulatives, 70424)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 01, 22, 0, 0))
    array.push(btc_cumulatives, 70784)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 02, 2, 0, 0))
    array.push(btc_cumulatives, 71079)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 02, 24, 0, 0))
    array.push(btc_cumulatives, 90531)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 03, 1, 0, 0))
    array.push(btc_cumulatives, 90859)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 03, 5, 0, 0))
    array.push(btc_cumulatives, 91064)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 03, 12, 0, 0))
    array.push(btc_cumulatives, 91326)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 04, 5, 0, 0))
    array.push(btc_cumulatives, 91579)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 05, 13, 0, 0))
    array.push(btc_cumulatives, 91850)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 05, 18, 0, 0))
    array.push(btc_cumulatives, 92079)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 06, 21, 0, 0))
    array.push(btc_cumulatives, 105085)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 08, 24, 0, 0))
    array.push(btc_cumulatives, 108992)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 09, 13, 0, 0))
    array.push(btc_cumulatives, 114042)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 11, 29, 0, 0))
    array.push(btc_cumulatives, 121044)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 12, 9, 0, 0))
    array.push(btc_cumulatives, 122478)

    array.push(btc_dates, timestamp(syminfo.timezone, 2021, 12, 30, 0, 0))
    array.push(btc_cumulatives, 124391)

    array.push(btc_dates, timestamp(syminfo.timezone, 2022, 01, 31, 0, 0))
    array.push(btc_cumulatives, 125051)

    array.push(btc_dates, timestamp(syminfo.timezone, 2022, 04, 5, 0, 0))
    array.push(btc_cumulatives, 129218)

    array.push(btc_dates, timestamp(syminfo.timezone, 2022, 06, 29, 0, 0))
    array.push(btc_cumulatives, 129699)

    array.push(btc_dates, timestamp(syminfo.timezone, 2022, 09, 20, 0, 0))
    array.push(btc_cumulatives, 130000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2022, 12, 27, 0, 0))
    array.push(btc_cumulatives, 132500)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 03, 27, 0, 0))
    array.push(btc_cumulatives, 138955)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 05, 4, 0, 0))
    array.push(btc_cumulatives, 140000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 06, 28, 0, 0))
    array.push(btc_cumulatives, 152333)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 08, 1, 0, 0))
    array.push(btc_cumulatives, 152800)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 09, 25, 0, 0))
    array.push(btc_cumulatives, 158245)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 11, 1, 0, 0))
    array.push(btc_cumulatives, 158400)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 11, 30, 0, 0))
    array.push(btc_cumulatives, 174530)

    array.push(btc_dates, timestamp(syminfo.timezone, 2023, 12, 27, 0, 0))
    array.push(btc_cumulatives, 189150)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 02, 6, 0, 0))
    array.push(btc_cumulatives, 190000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 02, 26, 0, 0))
    array.push(btc_cumulatives, 193000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 03, 11, 0, 0))
    array.push(btc_cumulatives, 205000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 03, 19, 0, 0))
    array.push(btc_cumulatives, 214246)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 04, 29, 0, 0))
    array.push(btc_cumulatives, 214400)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 06, 20, 0, 0))
    array.push(btc_cumulatives, 226331)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 08, 1, 0, 0))
    array.push(btc_cumulatives, 226500)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 09, 13, 0, 0))
    array.push(btc_cumulatives, 244800)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 09, 20, 0, 0))
    array.push(btc_cumulatives, 252220)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 11, 11, 0, 0))
    array.push(btc_cumulatives, 279420)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 11, 18, 0, 0))
    array.push(btc_cumulatives, 331200)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 11, 25, 0, 0))
    array.push(btc_cumulatives, 386700)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 12, 2, 0, 0))
    array.push(btc_cumulatives, 402100)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 12, 9, 0, 0))
    array.push(btc_cumulatives, 423650)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 12, 16, 0, 0))
    array.push(btc_cumulatives, 439000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 12, 23, 0, 0))
    array.push(btc_cumulatives, 444262)

    array.push(btc_dates, timestamp(syminfo.timezone, 2024, 12, 30, 0, 0))
    array.push(btc_cumulatives, 446400)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 01, 6, 0, 0))
    array.push(btc_cumulatives, 447470)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 01, 13, 0, 0))
    array.push(btc_cumulatives, 450000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 01, 21, 0, 0))
    array.push(btc_cumulatives, 461000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 01, 27, 0, 0))
    array.push(btc_cumulatives, 471107)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 02, 10, 0, 0))
    array.push(btc_cumulatives, 478740)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 02, 24, 0, 0))
    array.push(btc_cumulatives, 499096)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 03, 23, 0, 0))
    array.push(btc_cumulatives, 506137)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 03, 31, 0, 0))
    array.push(btc_cumulatives, 528185)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 04, 14, 0, 0))
    array.push(btc_cumulatives, 531644)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 04, 21, 0, 0))
    array.push(btc_cumulatives, 538200)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 05, 12, 0, 0))
    array.push(btc_cumulatives, 568840)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 05, 19, 0, 0))
    array.push(btc_cumulatives, 576230)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 05, 28, 0, 0))
    array.push(btc_cumulatives, 580250)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 06, 09, 0, 0))
    array.push(btc_cumulatives, 582000)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 06, 16, 0, 0))
    array.push(btc_cumulatives, 592100)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 06, 23, 0, 0))
    array.push(btc_cumulatives, 592345)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 06, 30, 0, 0))
    array.push(btc_cumulatives, 597325)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 07, 14, 0, 0))
    array.push(btc_cumulatives, 601550)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 07, 21, 0, 0))
    array.push(btc_cumulatives, 607770)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 07, 29, 0, 0))
    array.push(btc_cumulatives, 628791)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 08, 11, 0, 0))
    array.push(btc_cumulatives, 628946)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 08, 18, 0, 0))
    array.push(btc_cumulatives, 629376)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 08, 25, 0, 0))
    array.push(btc_cumulatives, 632457)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 09, 02, 0, 0))
    array.push(btc_cumulatives, 636505)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 09, 08, 0, 0))
    array.push(btc_cumulatives, 638460)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 09, 15, 0, 0))
    array.push(btc_cumulatives, 638985)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 09, 22, 0, 0))
    array.push(btc_cumulatives, 639835)


    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 10, 13, 0, 0))
    array.push(btc_cumulatives, 640031)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 10, 20, 0, 0))
    array.push(btc_cumulatives, 640418)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 10, 27, 0, 0))
    array.push(btc_cumulatives, 640808)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 11, 04, 0, 0))
    array.push(btc_cumulatives, 641025)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 11, 10, 0, 0))
    array.push(btc_cumulatives, 641692)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 11, 17, 0, 0))
    array.push(btc_cumulatives, 649870)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 12, 15, 0, 0))
    array.push(btc_cumulatives, 671268)

    array.push(btc_dates, timestamp(syminfo.timezone, 2025, 12, 29, 0, 0))
    array.push(btc_cumulatives, 672497)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 01, 12, 0, 0))
    array.push(btc_cumulatives, 687410)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 01, 20, 0, 0))
    array.push(btc_cumulatives, 709715)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 01, 26, 0, 0))
    array.push(btc_cumulatives, 712647)
    
    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 02, 02, 0, 0))
    array.push(btc_cumulatives, 713502)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 02, 09, 0, 0))
    array.push(btc_cumulatives, 714644)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 02, 17, 0, 0))
    array.push(btc_cumulatives, 717131)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 02, 23, 0, 0))
    array.push(btc_cumulatives, 717722)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 03, 02, 0, 0))
    array.push(btc_cumulatives, 720737)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 03, 09, 0, 0))
    array.push(btc_cumulatives, 738731)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 03, 16, 0, 0))
    array.push(btc_cumulatives, 761068)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 03, 23, 0, 0))
    array.push(btc_cumulatives, 762099)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 04, 06, 0, 0))
    array.push(btc_cumulatives, 766970)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 04, 13, 0, 0))
    array.push(btc_cumulatives, 780897)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 04, 20, 0, 0))
    array.push(btc_cumulatives, 815061)

    array.push(btc_dates, timestamp(syminfo.timezone, 2026, 04, 27, 0, 0))
    array.push(btc_cumulatives, 818334)


// Find the most recent BTC total matching the bar
float btc_held = na
for i = array.size(btc_dates) - 1 to 0 by 1
    if time >= array.get(btc_dates, i)
        btc_held := array.get(btc_cumulatives, i)
        break

// Price Data
spot = request.security('INDEX:BTCUSD', timeframe.period, close)
cme = request.security('CME:BTC1!', timeframe.period, close)
mstr = request.security('NASDAQ:MSTR', timeframe.period, close)

// MSTR Data
shares = request.financial('NASDAQ:MSTR', 'TOTAL_SHARES_OUTSTANDING', 'FQ')
debt = request.financial('NASDAQ:MSTR', 'TOTAL_DEBT', 'FQ')
cash = request.financial('NASDAQ:MSTR', 'CASH_N_EQUIVALENTS', 'FQ')
EPS = request.financial('NASDAQ:MSTR', 'EARNINGS_ESTIMATE', 'FQ')
FCF = request.financial('NASDAQ:MSTR', 'FREE_CASH_FLOW', 'TTM')
revenue = request.financial('NASDAQ:MSTR', 'TOTAL_REVENUE', 'TTM')

// MSTR Calcs
market_cap = mstr * shares
enterprise_value = market_cap + debt - cash
btc_holdings = btc_held * spot

// MSTR Metrics
metric = input.string(title = 'Metrics', options = ['NAV Premium', 'BTC Holdings %', 'BTC Holdings Per 100 Shares', 'BTC Correlation', 'Equivalent Share Price', 'P/E Ratio (equiv)', 'Price to FCF (equiv)', 'Price to Revenue (equiv)', 'Share Price Denominated in BTC Held'], defval = 'NAV Premium')
mcev = input(true, 'Use Enterprise Value Instead Of Market Cap')
val = mcev ? enterprise_value : market_cap

nav_premium = val / btc_holdings

btc_percent = btc_holdings / val * 100

btc_100_shares = btc_holdings / spot / shares * 100

share_price = (val - btc_holdings) / shares

length = input(20, title = 'Correlation Length')
c = ta.correlation(mstr, cme, length)

pe_ratio = share_price / (EPS * 4)

price_fcf = (val - btc_holdings) / FCF

price_revenue = (val - btc_holdings) / revenue

share_price_denominated = market_cap / (btc_holdings / spot)


// Plot
metric_plot = metric == 'NAV Premium' ? nav_premium : metric == 'BTC Holdings %' ? btc_percent : metric == 'BTC Holdings Per 100 Shares' ? btc_100_shares : metric == 'BTC Correlation' ? c : metric == 'Equivalent Share Price' ? share_price : metric == 'P/E Ratio (equiv)' ? pe_ratio : metric == 'Price to FCF (equiv)' ? price_fcf : metric == 'Price to Revenue (equiv)' ? price_revenue : share_price_denominated

plot(metric_plot, 'Metric', color = color.orange, linewidth = 2)


// Pinnacle_Investor
````
