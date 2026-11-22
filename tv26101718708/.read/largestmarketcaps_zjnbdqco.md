# LargestMarketCaps

- url: https://www.tradingview.com/script/zJnBdQco-LargestMarketCaps/
- type: strategy
- pine_id: PUB;1f68aa45c9a14a4b84d1b3db42f36dfe
- version: 1.0

## Description

This trading system uses a MA to check if the LARGEST CAP stocks are above or below the MA. 

You can see from the indicator below how well it manages to capture big moves.

[list]
[*] It aggregates the data of all the tickers to create the histogram indicator at the bottom of the chart called MarketLeaders. 
[*] If a ticker is above its moving average, then the output will increase by +1 and -1 if a ticker is below its moving average.
[*] This is a powerful system because it uses not only data from one stock but from the stocks that really affect the market big time. If those stocks don't do well, the market won't do well either.
[*] [/list]

[list]
[*] Basically if all the market leaders are doing well, then this system will buy those 20 tickers and keep positions open until the MarketLeaders indicator crosses below 0 -- meaning red.
[*] It also has a red stop loss line, with a wide 15% stop loss to keep us in the trades for the long term.
[*] I've used a 5-day chart because I wanted fewer signals, but higher quality signals.
[*] There are no profit targets, this exits when the indicator turns red -- meaning below 0 or if a position falls 15% in price.
[*] The MA setting is adjustable, the default is 20
[/list]


[b]These are the tickers that the strategy and indicator currently looks at[/b]
The tickers will need to be updated every 6-12 months to remove and ad those who have dropped out of the largest 20 stocks.
It would be a good idea to create a watchlist and alerts for the Large Cap tickers so you can scroll through to see how the system performed on each ticker
"SPX"
"QQQ"    
"AAPL"      
"MSFT"      
"GOOG"      
"FB"     
"BRK.A" 
"TSLA"      
"V" 
"JPM"    
"WMT"    
"UNH"
"MA"  
"KO"     
"PYPL"      
"PG"     
"HD"     
"DIS"    
"BAC"    
"ADBE"      
"CMCSA"  
"NKE"

[b]RELATED IDEAS /  Indicators[/b]

[*] Market Leaders Ribbon
https://www.tradingview.com/script/ZkvST1ne-MarketLeaders/

[*] Market Leaders Large Performance Table
https://www.tradingview.com/script/hVCZ4Jr1-Largest-Market-Cap-Performance/

## Source Code

````pine
// © HermanBrummer
// @version=4
strategy("LargestMarketCaps", "LargestMarketCaps", 1)

len             = input(20)
ma              = sma(close, len)


///     WIDE 15% STOP
///     USES THE MARKET LEAERS TO CREATEA COMBINED COUNTER THAT CHECKS IF THE MARKET LEADERS AS A GROUP ARE ABOVE THEIR MA'S OR NOT
///     FOCUS ON 20 LARGEST MARKETCAP STOCKS -- THESE WILL NEED TO BE UPDATED EVERY 6 MONTHS OR SO
plot(ma, "Moving Average", color.yellow, 2)


///     IMPORT TICKERS
t_01            = security("SPX",       "", ohlc4)      
t_02            = security("QQQ",       "", ohlc4)      
t_03            = security("AAPL",      "", ohlc4)      
t_04            = security("MSFT",      "", ohlc4)      
t_05            = security("GOOG",      "", ohlc4)      
t_06            = security("FB",        "", ohlc4)      
t_07            = security("BRK.A",     "", ohlc4)      
t_08            = security("TSLA",      "", ohlc4)      
t_09            = security("V",         "", ohlc4)      
t_10            = security("JPM",       "", ohlc4)      
t_11            = security("WMT",       "", ohlc4)      
t_12            = security("UNH",       "", ohlc4)  
t_13            = security("MA",        "", ohlc4)   
t_14            = security("KO",        "", ohlc4)      
t_15            = security("PYPL",      "", ohlc4)      
t_16            = security("PG",        "", ohlc4)      
t_17            = security("HD",        "", ohlc4)      
t_18            = security("DIS",       "", ohlc4)      
t_19            = security("BAC",       "", ohlc4)      
t_20            = security("ADBE",      "", ohlc4)      
t_21            = security("CMCSA",     "", ohlc4)      
t_22            = security("NKE",       "", ohlc4)


///     ABOVE MA?
i01             = t_01 > sma(t_01, len) ? 1 : -1
i02             = t_02 > sma(t_02, len) ? 1 : -1
i03             = t_03 > sma(t_03, len) ? 1 : -1
i04             = t_04 > sma(t_04, len) ? 1 : -1
i05             = t_05 > sma(t_05, len) ? 1 : -1
i06             = t_06 > sma(t_06, len) ? 1 : -1
i07             = t_07 > sma(t_07, len) ? 1 : -1
i08             = t_08 > sma(t_08, len) ? 1 : -1
i09             = t_09 > sma(t_09, len) ? 1 : -1
i10             = t_10 > sma(t_10, len) ? 1 : -1
i11             = t_11 > sma(t_11, len) ? 1 : -1
i12             = t_12 > sma(t_12, len) ? 1 : -1
i13             = t_13 > sma(t_13, len) ? 1 : -1
i14             = t_14 > sma(t_14, len) ? 1 : -1
i15             = t_15 > sma(t_15, len) ? 1 : -1
i16             = t_16 > sma(t_16, len) ? 1 : -1
i17             = t_17 > sma(t_17, len) ? 1 : -1
i18             = t_18 > sma(t_18, len) ? 1 : -1
i19             = t_19 > sma(t_19, len) ? 1 : -1
i20             = t_20 > sma(t_20, len) ? 1 : -1
i21             = t_21 > sma(t_21, len) ? 1 : -1
i22             = t_22 > sma(t_22, len) ? 1 : -1


Count           = i01+i02+i03+i04+i05+i06+i07+i08+i09+i10+i11+i12+i13+i14+i15+i16+i17+i18+i19+i20+i21+i22
col             = Count > 0 ? #00ff00 : #ff0000

//plot(Count, "MarketLeaders", col, 4, style=plot.style_histogram)

F1              = Count > 0 and close > ma and close[1] > ma
F2              = strategy.position_size == 0

enter           = F1 and F2

strategy.entry("Enter", true, when=crossover(Count,0))

StopLossLine    = strategy.position_avg_price*.85

strategy.exit("Exit", stop=StopLossLine)

///     Exits the market when market leaders """AS A GROUP""" are no longer above their MA
strategy.close_all(when=Count<0)

plot(StopLossLine, "Stop Loss", #ff0000 )
````
