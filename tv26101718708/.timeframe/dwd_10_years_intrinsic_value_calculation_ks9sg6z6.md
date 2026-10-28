# DWD 10 years Intrinsic value calculation

- url: https://www.tradingview.com/script/kS9Sg6Z6-DWD-10-years-Intrinsic-value-calculation/
- type: indicator
- pine_id: PUB;89b85e88cfa14983877a0f970591a405
- version: 1.0

## Description

[url=https://www.tradingview.com/x/uqy65Mrb/]https://www.tradingview.com/x/uqy65Mrb/[/url]

[url=https://www.tradingview.com/x/NwYQE6Ww/]https://www.tradingview.com/x/NwYQE6Ww/[/url]

This 10 year intrinsic value calculation is useful for me. It use Graham's definition. When I use it on some high tech companies, I time it 3. It worked very well.
For example, I will add more GOOG when it close to the lime color line, or below the lime line, about $320.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6

indicator('DWD 10 years Intrinsic value calculation', max_bars_back = 100, overlay = true)

var tickname = syminfo.ticker
growth_guess = input(title = 'growth rate', defval = 10)
Period = input.string(title = 'Financial Period', defval = 'FY', options = ['FQ', 'FY'])
EPS = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_BASIC', 'TTM') //EPS for the trailing twelve months
EPS_FWD = request.financial(syminfo.tickerid, 'EARNINGS_ESTIMATE', 'FY') //EPS estimate next year
Ebit = request.financial(syminfo.tickerid, 'EBIT', 'FQ')
Assets = request.financial(syminfo.tickerid, 'TOTAL_ASSETS', 'FQ')
Current = request.financial(syminfo.tickerid, 'TOTAL_CURRENT_LIABILITIES', 'FQ')
EPS_D_Y = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_DILUTED', 'FY')
EPS_D_Q = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_DILUTED', 'FQ')

BVPS = request.financial(syminfo.tickerid, 'BOOK_VALUE_PER_SHARE', 'FY') //Book Value
BVPS_Q = request.financial(syminfo.tickerid, 'BOOK_VALUE_PER_SHARE', 'FQ')
DVPS = request.financial(syminfo.tickerid, 'DPS_COMMON_STOCK_PRIM_ISSUE', Period) //Dividends per share
DVPR = request.financial(syminfo.tickerid, 'DIVIDEND_PAYOUT_RATIO', Period) //Dividend payout ratio
ROI = request.financial(syminfo.tickerid, 'RETURN_ON_INVESTED_CAPITAL', Period) //Return on investment
ROE = request.financial(syminfo.tickerid, 'RETURN_ON_EQUITY', Period) //Return on equity
PE_FWD = request.financial(syminfo.tickerid, 'PRICE_EARNINGS_FORWARD', Period) //PE estimate next year
GROWTH = request.financial(syminfo.tickerid, 'SUSTAINABLE_GROWTH_RATE', Period)
EPS_1year_g = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH', Period)
TOTAL_EQUITY = request.financial(syminfo.tickerid, 'TOTAL_EQUITY', Period)
OPMARGIN = request.financial(syminfo.tickerid, 'NET_MARGIN', 'FY')
graham_q = request.financial(syminfo.tickerid, 'GRAHAM_NUMBERS', 'FQ')
graham_y = request.financial(syminfo.tickerid, 'GRAHAM_NUMBERS', 'FY')
ROIC_Y = request.financial(syminfo.tickerid, 'RETURN_ON_INVESTED_CAPITAL', 'FY')
ROIC_Q = request.financial(syminfo.tickerid, 'RETURN_ON_INVESTED_CAPITAL', 'FQ')
ROCE_Q = Ebit / (Assets - Current)

us10y = request.security('US10Y', 'D', close)
yield_100 = ta.sma(us10y, 20)
bv_empty = true
years = input.float(title = 'How many years back?', defval = 20)
//bv_old = input(title="What was the Book Value then?", type=input.float, defval=9)
bv_new = request.financial(syminfo.tickerid, 'BOOK_VALUE_PER_SHARE', 'FY')
bv2_new = request.financial(syminfo.tickerid, 'BOOK_VALUE_PER_SHARE', 'FQ')
bv = request.financial(syminfo.tickerid, 'BOOK_VALUE_PER_SHARE', 'FY')
note = request.security('TVC:TNX', 'M', close) / 100

div = request.financial(syminfo.tickerid, 'DPS_COMMON_STOCK_PRIM_ISSUE', 'FQ')
net_income = request.financial(syminfo.tickerid, 'NET_INCOME', 'FY')
depre_amort = request.financial(syminfo.tickerid, 'DEP_AMORT_EXP_INCOME_S', 'FY')
capit_expend = request.financial(syminfo.tickerid, 'CAPITAL_EXPENDITURES', 'FY')
owner_earn = net_income + depre_amort - capit_expend
long_term_yield = request.security('TVC:TNX', 'D', close)

company_value = owner_earn / (1 + yield_100 / 10)
share = request.financial(syminfo.tickerid, 'TOTAL_SHARES_OUTSTANDING', 'FY')

GrahamValue = math.sqrt(15 * 1.5 * EPS * BVPS) //Graham value = square root ( 15 * 1.5 * EPS_TTM * Book Value per share)
graham_5 = ta.sma(GrahamValue, 5)
if ROIC_Q > 0 and ROIC_Q < 10
    graham_5 := graham_5 * math.sqrt(ROIC_Q / 10)
    graham_5
plot(graham_q, title = 'graham', color = color.green, linewidth = 3)
plot(graham_5, title = 'Graham Value', color = color.new(color.blue, 0), linewidth = 2)
plot(graham_q * 3, title = '3graham', color = color.lime, linewidth = 3)
plot(bv2_new, title = 'BV', color = color.new(color.olive, 0))
//plot(div, title='div', color=color.new(color.orange, 0))
//
````
