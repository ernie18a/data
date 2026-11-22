# SIP Evaluator and Screener [Trendoscope®]

- url: https://www.tradingview.com/script/Hxxk64fl-SIP-Evaluator-and-Screener-Trendoscope/
- type: indicator
- pine_id: PUB;f12ee680097e48bf8b2269c7420986a0
- version: 2.0

## Description

The SIP Evaluator and Screener [Trendoscope®] is a Pine Script indicator designed for TradingView to calculate and visualize Systematic Investment Plan (SIP) returns across multiple investment instruments. It is tailored for use in TradingView's screener, enabling users to evaluate SIP performance for various assets efficiently. 

[b]🎲 How SIP Works[/b]

A [b]Systematic Investment Plan[/b] (SIP) is an investment strategy where a fixed amount is invested at regular intervals (e.g., monthly or weekly) into a financial instrument, such as stocks, mutual funds, or ETFs. The goal is to build wealth over time by leveraging the power of compounding and mitigating the impact of market volatility through disciplined, consistent investing. Here’s a breakdown of how SIPs function:
[list]
[*][b]Regular Investments[/b]: In an SIP, an investor commits to investing a fixed sum at predefined intervals, regardless of market conditions. This consistency helps inculcate a habit of saving and investing.
[*][b]Cost Averaging[/b]: By investing a fixed amount regularly, investors purchase more units when prices are low and fewer units when prices are high. This approach, known as dollar-cost averaging, reduces the average cost per unit over time and mitigates the risk of investing a large amount at a peak price.
[*][b]Compounding Benefits[/b]: Returns generated from the invested amount (e.g., capital gains or dividends) are reinvested, leading to exponential growth over the long term. The longer the investment horizon, the greater the potential for compounding to amplify returns.
[*][b]Dividend Reinvestment[/b]: In some SIPs, dividends received from the underlying asset can be reinvested to purchase additional units, further enhancing returns. Taxes on dividends, if applicable, may reduce the reinvested amount.
[*][b]Flexibility and Accessibility[/b]: SIPs allow investors to start with small amounts, making them accessible to a wide range of individuals. They also offer flexibility in terms of investment frequency and the ability to adjust or pause contributions.
[/list]
In the context of the [b]SIP Evaluator and Screener [Trendoscope®][/b], the script simulates an SIP by calculating the number of units purchased with each fixed investment, factoring in commissions, dividends, taxes and the chosen price reference (e.g., open, close, or average prices). It tracks the cumulative investment, equity value, and dividends over time, providing a clear picture of how an SIP would perform for a given instrument. This helps users understand the impact of regular investing and make informed decisions when comparing different assets in TradingView’s screener. It offers insights into key metrics such as total invested amount, dividends received, equity value, and the number of installments, making it a valuable resource for investors and traders interested in understanding long-term investment outcomes.

[b]🎲 Key Features[/b]
[list]
[*]Customizable Investment Parameters: Users can define the recurring investment amount, price reference (e.g., open, close, HL2, HLC3, OHLC4), and whether fractional quantities are allowed.
[*]Commission Handling: Supports both fixed and percentage-based commission types, adjusting calculations accordingly.
[*]Dividend Reinvestment: Optionally reinvests dividends after a user-specified period, with the ability to apply tax on dividends.
[*]Time-Bound Analysis: Allows users to set a start year for the analysis, enabling historical performance evaluation.
[*]Flexible Dividend Periods: Dividends can be evaluated based on bars, days, weeks, or months.
[*]Visual Outputs: Plots key metrics like total invested amount, dividends, equity value, and remainder, with customizable display options for clarity in the data window and chart.
[/list]
[b]🎲 Using the script as an indicator on Tradingview Supercharts[/b]

In order to use the indicator on charts, do the following.
[list]
[*] Load the instrument of your choice - Preferably a stable stocks,  ETFs.
[*] Chose monthly timeframe as lower timeframes are insignificant in this type of investment strategy
[*] Load the indicator SIP Evaluator and Screener [Trendoscope®] and set the input parameters as per your preference.
[/list]
Indicator plots, investment value, dividends and equity on the chart.
https://www.tradingview.com/x/bGrJ7hcz/

[b]🎲 Visualizations[/b]
[list]
[*][b]Installments[/b]: Displays the number of SIP installments (gray line, visible in the data window).
[*][b]Invested Amount[/b]: Shows the cumulative amount invested, excluding reinvested dividends (blue area plot).
[*][b]Dividends[/b]: Tracks total dividends received (green area plot).
[*][b]Equity[/b]: Represents the current market value of the investment based on the closing price (purple area plot).
[*][b]Remainder[/b]: Indicates any uninvested cash after each installment (gray line, visible in the data window).
[/list]
[b]🎲 Deep dive into the settings[/b]

The SIP Evaluator and Screener [Trendoscope®] offers a range of customizable settings to tailor the Systematic Investment Plan (SIP) simulation to your preferences. Below is an explanation of each setting, its purpose, and how it impacts the analysis:

[b]🎯 Duration[/b]
[list]
[*][b]Start Year (Default: 2020)[/b]: Specifies the year from which the SIP calculations begin. When Start Year is enabled via the timebound option, the script only considers data from the specified year onward. This is useful for analyzing historical SIP performance over a defined period. If disabled, the script uses all available data.
[*][b]Timebound (Default: False)[/b]: A toggle to enable or disable the Start Year restriction. When set to False, the SIP calculation starts from the earliest available data for the instrument.
[/list]
[b]🎯 Investment[/b]
[list]
[*][b]Recurring Investment (Default: 1000.0)[/b]: The fixed amount invested in each SIP installment (e.g., $1000 per period). This represents the regular contribution to the SIP and directly influences the total invested amount and quantity purchased.
[*][b]Allow Fractional Qty (Default: True)[/b]: When enabled, the script allows the purchase of fractional units (e.g., 2.35 shares). If disabled, only whole units are purchased (e.g., 2 shares), with any remaining funds carried forward as Remainder. This setting impacts the precision of investment allocation.
[*][b]Price Reference (Default: OPEN):[/b] Determines the price used for purchasing units in each SIP installment. Options include:
[list=1]
[*][b]OPEN[/b]: Uses the opening price of the bar.
[*][b]CLOSE[/b]: Uses the closing price of the bar.
[*][b]HL2[/b]: Uses the average of the high and low prices.
[*][b]HLC3[/b]: Uses the average of the high, low, and close prices.
[*][b]OHLC4[/b]: Uses the average of the open, high, low, and close prices. This setting affects the cost basis of each purchase and, consequently, the total quantity and equity value.
[/list]
[/list]
[b]🎯 Commission[/b]
[list]
[*][b]Commission (Default: 3)[/b]: The commission charged per SIP installment, expressed as either a fixed amount (e.g., $3) or a percentage (e.g., 3% of the investment). This reduces the amount available for purchasing units.
[*][b]Commission Type (Default: Fixed)[/b]: Specifies how the commission is calculated:
[list=1]
[*][b]Fixed ($)[/b]: A flat fee is deducted per installment (e.g., $3).
[*][b]Percentage (%)[/b]: A percentage of the investment amount is deducted as commission (e.g., 3% of $1000 = $30). This setting affects the net amount invested and the overall cost of the SIP.
[/list]
[/list]
[b]🎯 Dividends[/b]
[list]
[*] [b]Apply Tax On Dividends (Default: False)[/b]: When enabled, a tax is applied to dividends before they are reinvested or recorded. The tax rate is set via the Dividend Tax setting.
[*] [b]Dividend Tax (Default: 47)[/b]: The percentage of tax deducted from dividends if Apply Tax On Dividends is enabled (e.g., 47% tax reduces a $100 dividend to $53). This reduces the amount available for reinvestment or accumulation.
[*] [b]Reinvest Dividends After (Default: True, 2)[/b]: When enabled, dividends received are reinvested to purchase additional units after a specified period (e.g., 2 units of time, defined by Dividends Availability). If disabled, dividends are tracked but not reinvested. Reinvestment increases the total quantity and equity over time.
[*] [b]Dividends Availability (Default: Bars)[/b]: Defines the time unit for evaluating when dividends are available for reinvestment. Options include:
[list=1]
[*] [b]Bars[/b]: Based on the number of chart bars.
[*] [b]Weeks[/b]: Based on weeks.
[*] [b]Months[/b]: Based on months (approximated as 30.5 days). This setting determines the timing of dividend reinvestment relative to the Reinvest Dividends After period.
[/list]
[/list]
[b]🎯 How Settings Interact[/b]

These settings work together to simulate a realistic SIP. For example, a $1000 recurring investment with a 3% commission and fractional quantities enabled will calculate the number of units purchased at the chosen price reference after deducting the commission. If dividends are reinvested after 2 months with a 47% tax, the script fetches dividend data, applies the tax, and adds the net dividend to the investment amount for that period. The Start Year and Timebound settings ensure the analysis aligns with the desired timeframe, while the Dividends Availability setting fine-tunes dividend reinvestment timing.

By adjusting these settings, users can model different SIP scenarios, compare performance across instruments in TradingView’s screener, and gain insights into how commissions, dividends, and price references impact long-term returns.

https://www.tradingview.com/x/OeO8vh7K/

[b]🎲 Using the script with Pine Screener[/b]
The main purpose of developing this script is to use it with Tradingview Pine Screener so that multiple ETFs/Funds can be compared.

In order to use this as a screener, the following things needs to be done.
[list=1]
[*] Add SIP Evaluator and Screener [Trendoscope®] to your favourites (Required for it to be added in pine screener)
[*] Create a watch list containing required instruments to compare
[*] Open pine screener from Tradingview main menu [b]Products -> Screeners -> Pine[/b] or simply load the URL - https://www.tradingview.com/pine-screener/
[*] Select the watchlist created from Watchlist dropdown. 
[*] Chose the SIP Evaluator and Screener [Trendoscope®] from the [b]"Choose Indicator"[/b] dropdown
[*] Set timeframe to 1 month and update settings as required.
[*] Press scan to display collected data on the screener.
[/list]

https://www.tradingview.com/x/MR3O6g7p/

[b]🎲 Use Case[/b]

This indicator is ideal for educational purposes, allowing users to experiment with SIP strategies across different instruments. It can be applied in TradingView’s screener to compare SIP performance for stocks, ETFs, or other assets, helping users understand how factors like commissions, dividends, and price references impact returns over time.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=6
indicator('SIP Evaluator and Screener [Trendoscope®]', shorttitle = 'SC [Trendoscope®]', overlay = false)

enum PriceReference
    OPEN
    CLOSE
    HL2
    HLC3
    OHLC4

enum Period
    Bars
    Weeks
    Months

enum CommissionType
    Fixed = '$'
    Percentage = '%'

durationTooltip = 'Specifies the year from which the SIP calculations begin. When Start Year is enabled via the timebound option, '+
                         'the script only considers data from the specified year onward. This is useful for analyzing historical SIP performance '+
                         'over a defined period. If disabled, the script uses all available data.'
pricePrefereceTooltip = 'Determines the price used for purchasing units in each SIP installment. Options include: OPEN, CLOSE, HL2, HLC3, OHLC4'
recurringInvestmentTooltip = 'The fixed amount invested in each SIP installment (e.g., $1000 per period). '+
                                 'This represents the regular contribution to the SIP and directly influences the total invested amount and quantity purchased.'
allowFractionalTooltip = 'When enabled, the script allows the purchase of fractional units (e.g., 2.35 shares). '+
                             'If disabled, only whole units are purchased (e.g., 2 shares), with any remaining funds carried forward as Remainder. '+
                             'This setting impacts the precision of investment allocation.'
commissionTooltip = 'The commission charged per SIP installment, expressed as either a fixed amount (e.g., $3) or a percentage (e.g., 3% of the investment). '+
                             'This reduces the amount available for purchasing units.'
taxOnDividendTooltip = 'When enabled, a tax is applied to dividends before they are reinvested or recorded. '+
                             'The percentage of tax deducted from dividends if Apply Tax On Dividends is enabled '+
                             '(e.g., 47% tax reduces a $100 dividend to $53). This reduces the amount available for reinvestment or accumulation.'
reinvestDividendsTooltip = 'When enabled, dividends received are reinvested to purchase additional units after a specified period (e.g., 2 units of time, defined by Dividends Availability). '+
                             'If disabled, dividends are tracked but not reinvested. Reinvestment increases the total quantity and equity over time.'
timebound = input.bool(false, 'Start Year', inline = 't1', group = 'Duration', display = display.none)
startYear = input.int(2020, '', tooltip = durationTooltip, inline = 't1', group = 'Duration', display = display.none)
priceReference = input.enum(PriceReference.OPEN, 'Price Reference', tooltip = pricePrefereceTooltip, group = 'Investment', display = display.none)
incrementalInvestment = input.float(1000.0, 'Recurring Investment', tooltip = recurringInvestmentTooltip, group = 'Investment', display = display.none)
allowFractional = input.bool(true, 'Allow Fractional Qty', allowFractionalTooltip, group = 'Investment', display = display.none)

commissionValue = input.float(3, 'Commission', group = 'Commission', inline='c', display = display.none)
commissionType = input.enum(CommissionType.Fixed, '', group='Commission', inline='c', tooltip = commissionTooltip, display = display.none)

reinvestDividends = input.bool(true, 'Reinvest Dividends After', reinvestDividendsTooltip, group = 'Dividends', display = display.none, inline='ri')
dividendsAfter = input.int(2, '', group = 'Dividends', display = display.none, inline='ri')
dividendsAvailability = input.enum(Period.Bars, '', group = 'Dividends', display = display.none, inline='ri')
applyTax = input.bool(false, 'Apply Tax On Dividends',group='Dividends', display = display.none, inline='tax')
dividendTax = input.float(47, '', tooltip = taxOnDividendTooltip, group='Dividends', display = display.none, inline='tax')
type Instalment
    float amount
    float commission
    float dividend
    float qty
    float price
    int startDate = time

type Investment
    float totalAmount =0.0
    float commission = 0.0
    float dividends = 0.0
    float totalQty = 0.0
    int numberOfInstallments = 0
    float remainder = 0.0
    int startDate

method add(Investment this, Instalment instalment, float remainder)=>
    if(na(this.startDate))
        this.startDate := time
    this.totalAmount += instalment.amount
    this.commission += instalment.commission
    this.dividends += instalment.dividend
    this.totalQty += instalment.qty
    this.numberOfInstallments+=1
    this.remainder := remainder

type Dividend
    float amount
    int dTime = time
    int dBar = bar_index

method diff(Period dividendsAvailability, int timeFrom, int timeTo)=>
    days = (timeTo-timeFrom)/(1000*86400)
    weeks = days/7
    months = days/30.5
    dividendsAvailability == Period.Bars? timeTo - timeFrom :
         dividendsAvailability == Period.Weeks? weeks : 
         months

var allDividends = array.new<Dividend>()

var investmentInstallments = array.new<Instalment>()
var totalInvestment = Investment.new()

dividend = request.dividends(syminfo.tickerid, gaps = barmerge.gaps_on, lookahead = barmerge.lookahead_off, ignore_invalid_symbol=true)
if(not na(dividend))
    allDividends.push(Dividend.new(dividend))

currentDividend = 0.0
if(allDividends.size() > 0)
    firstDividend = allDividends.first()
    timeDiff = dividendsAvailability.diff(dividendsAvailability == Period.Bars? firstDividend.dBar: firstDividend.dTime,
                                             dividendsAvailability == Period.Bars?bar_index: time)
    if(timeDiff >= dividendsAfter)
        currentDividend := firstDividend.amount*totalInvestment.totalQty*(applyTax?(100-dividendTax)/100 : 1)
        allDividends.shift()

if not timebound or year(time) >= startYear
    var float investmentCurrent = 0.0
    investmentCurrent := investmentCurrent + incrementalInvestment + (reinvestDividends?currentDividend:0)
    price = priceReference == PriceReference.OPEN? open :
                 priceReference == PriceReference.CLOSE? close : 
                 priceReference == PriceReference.HL2? hl2:
                 priceReference == PriceReference.HLC3? hlc3: ohlc4
    commissionAdjustment = (1+commissionValue/100)
    fixedCommission = (commissionType==CommissionType.Fixed? commissionValue : 0)
    availableAmount = investmentCurrent - fixedCommission
    consideredPrice = commissionType==CommissionType.Fixed?price:price*commissionAdjustment
    qty = availableAmount/consideredPrice
    qty := allowFractional? qty : math.floor(qty)
    amount = allowFractional? availableAmount : qty*consideredPrice
    commisionNow = commissionType==CommissionType.Fixed? commissionValue : amount*commissionValue/100
    investmentCurrent := investmentCurrent - amount - fixedCommission
    instalment = Instalment.new(amount+fixedCommission, commisionNow, currentDividend, qty, price)
    log.info('{0},  : {1} - {2} // {3} // {4}', amount+fixedCommission, commisionNow, currentDividend, qty, investmentCurrent)
    totalInvestment.add(instalment, investmentCurrent)

gain = (totalInvestment.totalQty*close-(totalInvestment.totalAmount-(reinvestDividends?totalInvestment.dividends:0)))*100 / (totalInvestment.totalAmount-(reinvestDividends?totalInvestment.dividends:0))
plot(totalInvestment.numberOfInstallments, 'Installments', color.gray, display = display.data_window)
plot(totalInvestment.totalAmount-(reinvestDividends?totalInvestment.dividends:0), 'Invested', color.new(color.blue, 80), format=format.price, style = plot.style_area)
plot(totalInvestment.dividends, 'Dividends', color.new(color.green, 60), format=format.price, style = plot.style_area)
plot(totalInvestment.totalQty*close, 'Equity', color.new(color.purple, 80), style = plot.style_area)
plot(totalInvestment.remainder, 'Remainder', color.gray, display = display.data_window)
plot(gain, 'Gain%', color=color.silver, display = display.data_window, format=format.percent)
````
