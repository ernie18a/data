# Xmaster Formula Indicator [TradingFinder] No Repaint Strategies

- url: https://www.tradingview.com/script/ghYlynnf-Xmaster-Formula-Indicator-TradingFinder-No-Repaint-Strategies/
- type: indicator
- pine_id: PUB;3ea35e8468bb4dfe95cb741735f3240b
- version: 1.0

## Description

🔵[b]Introduction[/b]

The Xmaster Formula Indicator is a powerful tool for forex trading, combining multiple technical indicators to provide insights into market trends, support and resistance levels, and price reversals. Developed in the early 2010s, it is widely valued for generating reliable buy and sell signals.

Key components include Exponential Moving Averages (EMA) for identifying trends and price momentum, and MACD (Moving Average Convergence Divergence) for analyzing trend strength and direction. 

The Stochastic Oscillator and RSI (Relative Strength Index) enhance accuracy by signaling potential price reversals. Additionally, the Parabolic SAR assists in identifying trend reversals and managing risk.

By integrating these tools, the Xmaster Formula Indicator provides a comprehensive view of market conditions, empowering traders to make informed decisions.

🔵[b]How to Use[/b]

The Xmaster Formula Indicator offers two distinct methods for generating signals: Standard Mode and Advance Mode. Each method caters to different trading styles and strategies.

[i]Standard Mode[/i]:

In Standard Mode, the indicator uses normalized moving average data to generate buy and sell signals. The difference between the short-term (10-period) and long-term (38-period) EMAs is calculated and normalized to a 0-100 scale.

[i]Buy Signal[/i]: When the normalized value crosses above 55, accompanied by the trend line turning green, a buy signal is generated.

[i]Sell Signal[/i]: When the normalized value crosses below 45, and the trend line turns red, a sell signal is issued.

This mode is simple, making it ideal for traders looking for straightforward signals without the need for additional confirmations.

[image]https://www.tradingview.com/x/zWayD03o/[/image]


[i]Advance Mode[/i]:

Advance Mode combines multiple technical indicators to provide more detailed and robust signals. 

[i]This method analyzes trends by incorporating[/i]:

🟣[b]MACD[/b]
[i]Buy Signal[/i]: When the MACD histogram bars are positive.
[i]Sell Signal[/i]: When the MACD histogram bars are negative.

🟣[b]RSI[/b]
[i]Buy Signal[/i]: When RSI is below 30, indicating oversold conditions.
[i]Sell Signal[/i]: When RSI is above 70, suggesting overbought conditions.

🟣[b]Stochastic Oscillator[/b]

[i]Buy Signal[/i]: When Stochastic is below 20.
[i]Sell Signal[/i]: When Stochastic is above 80.

🟣[b]Parabolic SAR[/b]

[i]Buy Signal[/i]: When SAR is below the price.
[i]Sell Signal[/i]: When SAR is above the price.

[i]A signal is generated in Advance Mode only when all these indicators align[/i]:

[i]Buy Signal[/i]: All conditions point to a bullish trend.
[i]Sell Signal[/i]: All conditions indicate a bearish trend.

This mode is more comprehensive and suitable for traders who prefer deeper analysis and stronger confirmations before executing trades.

[image]https://www.tradingview.com/x/Sj9j4B1Z/[/image]

🔵[b]Settings[/b]

[i]Method[/i]:

Choose between "Standard" and "Advance" modes to determine how signals are generated. In Standard Mode, signals are based on normalized moving average data, while in Advance Mode, signals rely on the combination of MACD, RSI, Stochastic Oscillator, and Parabolic SAR.

[image]https://www.tradingview.com/x/I3yxUrXi/[/image]

[image]https://www.tradingview.com/x/9Dyzhc1Z/[/image]


[i]Moving Average Settings[/i]:

[i]Short Length[/i]: The period for the short-term EMA (default is 10).
[i]Mid Length[/i]: The period for the medium-term EMA (default is 20).
[i]Long Length[/i]: The period for the long-term EMA (default is 38).

[i]MACD Settings[/i]:

[i]Fast Length[/i]: The period for the fast EMA in the MACD calculation (default is 12).
[i]Slow Length[/i]: The period for the slow EMA in the MACD calculation (default is 26).
[i]Signal Line[/i]: The signal line period for MACD (default is 9).

[i]Stochastic Settings[/i]:

[i]Length[/i]: The period for the Stochastic Oscillator (default is 14).

[i]RSI Settings[/i]:

[i]Length[/i]: The period for the Relative Strength Index (default is 14).


🔵[b]Conclusion[/b]

The Xmaster Formula Indicator is a versatile and reliable tool for forex traders, offering both simplicity and advanced analysis through its Standard and Advance modes. In Standard Mode, traders benefit from straightforward signals based on normalized moving average data, making it ideal for quick decision-making. 

Advance Mode, on the other hand, provides a more detailed analysis by combining multiple indicators like MACD, RSI, Stochastic Oscillator, and Parabolic SAR, delivering stronger confirmations for critical market decisions.

While the Xmaster Formula Indicator offers valuable insights and reliable signals, it is important to use it alongside proper risk management and other analytical methods. By leveraging its capabilities effectively, traders can enhance their trading strategies and achieve better outcomes in the dynamic forex market.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab

//@version=6
indicator('Xmaster Formula Indicator [TradingFinder] No Repaint Strategy', 'TFlab Xmaster', overlay = false, max_bars_back = 5000, max_labels_count = 500)
import TradingView/ta/9

// inputs
Method = input.string('Advance', 'Method', ['Standard', 'Advance'], tooltip = 'In the advanced method, signals are generated based on the combination of the MACD, RSI, Stochastic,' + 
 'and Parabolic SAR indicators. In the standard mode, signals are based on normalized moving average data.')

MA_Short_len = input.int(10, 'Short Length Moving Average', group = 'Moving Average Setting')
MA_Mid_len   = input.int(20, 'Mid Length   Moving Average', group = 'Moving Average Setting')
MA_Long_len  = input.int(38, 'Long Length  Moving Average', group = 'Moving Average Setting')

MACD_Fast_len = input.int(12, 'Fast Length MACD', group = 'MACD Setting')
MACD_Slow_len = input.int(26, 'Slow Length MACD', group = 'MACD Setting')

Stoch_len     =  input.int(14, 'Slow Length Stochastic', group = 'Stochastic Setting')

RSI_len       =  input.int(14, 'Slow Length RSI', group = 'RSI Setting')

// variable
var string MACD_Trend  = na
var string RSI_Trend   = na
var string Stoch_Trend = na
var string SAR_Trend   = na
var string Trend       = na
var label Long_Signal  = na
var label Short_Signal = na
var color Color       = na

// indicator function
MA_Short = ta.ema(close, MA_Short_len)
MA_Mid   = ta.ema(close, MA_Mid_len  )
MA_Longt = ta.ema(close, MA_Long_len )

[MACD_Line, Signal_Line, Hist_Line] = ta.macd(close, MACD_Fast_len, MACD_Slow_len, 9)

Stoch = ta.stoch(close, high, low, Stoch_len)

RSI   = ta.rsi(close, RSI_len)

SAR = ta.sar(0.2, 0.2, 0.2)


//Standard Calculate
Diff_MA = (ta.ema(close,10) - ta.ema(close,38))

Diff_MA_Normal = (Diff_MA - ta.min(Diff_MA))/(ta.max(Diff_MA)-ta.min(Diff_MA)) * 100


//Advance Calculate
if Hist_Line > 0
    MACD_Trend := 'Long'
if Hist_Line < 0
    MACD_Trend := 'Short'

if RSI < 30 
    RSI_Trend := 'Long'
if RSI > 70
    RSI_Trend := 'Short'

if Stoch < 20 
    Stoch_Trend := 'Long'
if Stoch > 80
    Stoch_Trend := 'Short'

if SAR < low
    SAR_Trend   := 'Long'
if SAR > high
    SAR_Trend   := 'Short'

if (MACD_Trend == 'Long' and RSI_Trend == 'Long' and Stoch_Trend == 'Long' and SAR_Trend   == 'Long') 
    Trend := 'Long'

if (MACD_Trend == 'Short' and RSI_Trend == 'Short' and Stoch_Trend == 'Short' and SAR_Trend   == 'Short') 
    Trend := 'Short'


//Drawing
Color := if Method == 'Advance'
    if Diff_MA_Normal >= 55 
        color.green
    else if Diff_MA_Normal < 55 and Diff_MA_Normal > 45 
        color.orange
    else 
        color.red
else
    if Diff_MA_Normal > 55
        color.green
    else if Diff_MA_Normal < 45  
        color.red
    else
        Color := Color[1]

plot(Diff_MA_Normal, color = Color,linewidth = 3)
hline(50, linestyle = hline.style_dashed)
Top = hline(70, linestyle = hline.style_dotted)
Bottom = hline(30, linestyle = hline.style_dotted)
fill(Top,Bottom ,color = #ebedf5)

if Method == 'Advance'
    if Trend[1] == 'Short' and Trend == 'Long'
        Long_Signal := label.new(bar_index, Diff_MA_Normal, style = label.style_triangleup, color = #08530a, size = size.tiny)

    if Trend[1] == 'Long' and Trend == 'Short'
        Short_Signal := label.new(bar_index, Diff_MA_Normal, style = label.style_triangledown, color = #8f0909, size = size.tiny)
else 
    if Color[1] == color.red and Color == color.green
        Long_Signal := label.new(bar_index, Diff_MA_Normal, style = label.style_triangleup, color = #08530a, size = size.tiny)

    if Color[1] == color.green and Color == color.red
        Short_Signal := label.new(bar_index, Diff_MA_Normal, style = label.style_triangledown, color = #8f0909, size = size.tiny)
````
