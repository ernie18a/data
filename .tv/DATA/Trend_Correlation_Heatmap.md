<!-- tradingview-pine-id: PUB;6c12692ce4ef4acf9d3619dcbaba5038 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Correlation Heatmap

Source: https://www.tradingview.com/script/96Cld5iS-Trend-Correlation-Heatmap/

## Description

Hello everyone!

I am excited to release my trend correlation heatmap, or trend heatmap for short. 

Per usual, I think its important to explain the theory before we get into the use of the indicator, so let's get into the theory! 

The theory: 

So what is a correlation? 

Correlation is the relationship one variable has to another. Correlations are the basis of everything I do as a quantitative trader. From the correlation between the same variables (i.e. autocorrelation), the correlation between other variables (i.e. VIX and SPY, SPY High and SPY Low, DXY and ES1! close, etc.) and, as well, the correlation between price and time (time series correlation). 

This may sound very familiar to you, especially if you are a user, observer or follower of my ideas and/or indicators. Ninety-five percent of my indicators are a function of one of those three things. Whether it be a time series based indicator (i.e.my time series indicator), whether it be autocorrelation (my autoregressive cloud indicator or my autocorrelation oscillator) or whether it be regressive in nature (i.e. my SPY Volume weighted close, or even my expected move which uses averages in lieu of regressive approaches but is foundational in regression principles. Or even my VIX oscillator which relies on the premise of correlations between tickers.) So correlation is extremely important to me and while its true I am more of a regression trader than anything, I would argue that I am more of a correlation trader, because correlations are the backbone of how I develop math models of stocks. 

What I am trying to stress here is the importance of correlations. They really truly are foundational to any type of quantitative analysis for stocks. And as such, understanding the current relationship a stock has to time is pivotal for any meaningful analysis to be conducted.

So what is correlation to time and what does it tell us? 
Correlation to time, otherwise known and commonly referred to as "Time Series", is the relationship a ticker's price has to the passing of time. It is displayed in the traditional Pearson Correlation Coefficient or R value and can be any value from -1 (strong negative relationship, i.e. a strong downtrend) to + 1 (i.e. a strong positive relationship, i.e. a strong uptrend). The higher or lower the value the stronger the up or downtrend is. 

As such, correlation to time tells us two very important things. These are:
a) The direction of the stock; and 
b) The strength of the trend. 

Let's take a look at an example: 

https://www.tradingview.com/x/ZjfyJpzb/

Above we have a chart of QQQ. We can see a trendline that seems to fit well. The questions we ask as traders are:
1. What is the likelihood QQQ breaks down from this trendline? 
2. What is the likelihood QQQ continues up? 
3. What is the likelihood QQQ does a false breakdown? 

There are numerous mathematical approaches we can take to answer these questions. For example, 1 and 2 can be answered by use of a Cumulative Distribution Density analysis (CDDA) or even a linear or loglinear regression analysis and 3 can be answered, more or less, with a linear regression analysis and standard error ascertainment, or even just a general comparison using a data science approach (such as cosine similarity or Manhattan distance). 

But, the reality is, all 3 of these questions can be visualized, at least in some way, by simply looking at the correlation to time. Let's look at this chart again, this time with the correlation heatmap applied:

https://www.tradingview.com/x/1B6zrNCC/

If we look at the indicator we can see some pivotal things. These are:

1. We have 4, very strong uptrends that span both higher AND lower timeframes. We have a strong uptrend of 0.96 on the 5 minute, 50 candle period. We have a strong uptrend at the 300 candle lookback period on the 1 minute, we have a strong uptrend on the 100 day lookback on the daily timeframe period and we have a strong uptrend on the 5 minute on the 500 candle lookback period. 

2. By comparison, we have 3 downtrends, all of which have correlations less than the 4 uptrends. All of the downtrends have a correlation above -0.8 (which we would want lower than -0.8 to be very strong), and all of the uptrends are greater than + 0.80. 

3. We can also see that the uptrends are not confined to the smaller timeframes. We have multiple uptrends on multiple timeframes and both short term (50 to 100 candles) and long term (up to 500 candles). 

4. The overall trend is strengthening to the upside manifested by a positive Max Change and a Positive Min change (to be discussed later more in-depth). 

With this, we can see that QQQ is actually very strong and likely will continue at least some upside. If we let this play out:

https://www.tradingview.com/x/UOq4yyAo/

We continued up, had one test and then bounced. 

Now, I want to specify, this indicator is not a panacea for all trading. And in relation to the 3 questions posed, they are best answered, at least quantitatively, not only by correlation but also by the aforementioned methods (CDDA, etc.)  but correlation will help you get a feel for the strength or weakness present with a stock. 

What are some tangible applications of the indicator? 
For me, this indicator is used in many ways. Let me outline some ways I generally apply this indicator in my day and swing trading:

1. Gauging the strength of the stock: The indictor tells you the most prevalent behavior of the stock. Are there more downtrends than uptrends present? Are the downtrends present on the larger timeframes vs uptrends on the shorter indicating a possible bullish reversal? or vice versa? Are the trends strengthening or weakening? All of these things can be visualized with the indicator. 

2. Setting parameters for other indicators: If you trade EMAs or SMAs, you may have a "one size fits all" approach. However, its actually better to adjust your EMA or SMA length to the actual trend itself. Take a look at this:

https://www.tradingview.com/x/cUEbSuZh/

This is QQQ on the 1 hour with the 200 EMA with 200 standard deviation bands added. If we look at the heatmap, we can see, yes indeed 200 has a fairly strong uptrend correlation of 0.70. But the strongest hourly uptrend is actually at 400 candles, with a correlation of 0.91. So what happens if we change the EMA length and standard deviation to 400? This:

https://www.tradingview.com/x/x5LiKyIQ/

The exact areas are circled and colour coded. You can see, the 400 offers more of a better reference point of supports and resistances as well as a better overall trend fit. And this is why I never advocate for getting married to a specific EMA. If you are an EMA 200 lover or 21 or 51, know that these are not always the best depending on the trend and situation. 

Components of the indicator: 

Ah okay, now for the boring stuff. Let's go over the functionality of the indicator. I tried to keep it simple, so it is pretty straight forward. If we open the menu here are our options:

https://www.tradingview.com/x/7u3zJlI0/

We have the ability to toggle whichever timeframes we want. We also have the ability to toggle on or off the legend that displays the colour codes and the Max and Min highest change.

Max and Min highest change: The max and min highest change simply display the change in correlation over the previous 14 candles. An increasing Max change means that the Max trend is strengthening. If we see an increasing Max change and an increasing Min change (the Min correlation is moving up), this means the stock is bullish. Why? Because the min (i.e. ideally a big negative number) is going up closer to the positives. Therefore, the downtrend is weakening. 

If we see both the Max and Min declining (red), that means the uptrend is weakening and downtrend is strengthening. Here are some examples:

https://www.tradingview.com/x/V1IJWts6/

https://www.tradingview.com/x/RjCRheDQ/

Final Thoughts:

And that is the indicator and the theory behind the indicator. 
In a nutshell, to summarize, the indicator simply tracks the correlation of a ticker to time on multiple timeframes. This will allow you to make judgements about strength, sentiment and also help you adjust which tools and timeframes you are using to perform your analyses. 

As well, to make the indicator more user friendly, I tried to make the colours distinctively different. I was going to do different shades but it was a little difficult to visualize. As such, I have included a toggle-able legend with a breakdown of the colour codes! 

That's it my friends, I hope you find it useful! 

Safe trades and leave your questions, comments and feedback below!

---

## Source Code

````pine
//  /$$$$$$   /$$                                                         /$$                                            
// /$$__  $$ | $$                                                        | $$                                            
//| $$  \__//$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$$
//|  $$$$$$|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$__  $$ /$$_____/|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$_____/
// \____  $$ | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$| $$  \__/|  $$$$$$   | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$|  $$$$$$ 
// /$$  \ $$ | $$ /$$| $$_____/  \  $$$/ | $$_____/| $$       \____  $$  | $$ /$$| $$_____/  \  $$$/ | $$_____/ \____  $$
//|  $$$$$$/ |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$| $$       /$$$$$$$/  |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$ /$$$$$$$/
// \______/   \___/   \_______/    \_/    \_______/|__/      |_______/    \___/   \_______/    \_/    \_______/|_______/ 

//       ___________________
//      /                   \
//     /  _____        _____ \
//    /  /     \      /     \  \
// __/__/       \____/       \__\_____
//|           ___________           ____|
// \_________/           \_________/
//            \  /////// /
//             \/////////
// © Steversteves
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                           Information                                                                               ///
///                                                                                                                                                     ///
///The trend heatmap indicator looks at various trend correlations on up to 4 user defined timeframes.                                                  ///
///It will plot the trend from 50 to 500 by increments of 50 on each specified timeframe.                                                               ///
///It will assign a colour code to the trend correlation which specifies the strength and direction of the trend.                                       ///
/// A legend is provided within the indicator and can be toggled on our off. The default setting is to toggle it on.                                    ///
/// The indicator will provide the overall Strongest and Weakest trend based on the specified timeframes.                                               /// 
/// For example, if you select the following: 1 minute, 5 minute, 30 minute and 60 minute, the indicator will identify the strongest an weaknest trend  ///
/// between all of those designated timeframes.                                                                                                         ///
///                                                                                                                                                     ///
///The indicator will also identify the strongest uptrend and downtrend for each specified timeframe.                                                   ///
/// It is important to note that a significant downtrend or uptrend per timeframe is defined as the largest positive and negative correlation +         /// 
/// having a Pearon correaltion coefficient (R value) of greater than or = to 0.5 or -0.5 respectively.                                                 ///
///                                                                                                                                                     /// 
///                                                     Why care about trend correlations?                                                              ///
///                                                                                                                                                     ///
/// Trend correlations to time offer an objective way to mathmatically measure the strength of an uptrend or downtrend.                                 ///
/// Identifying where significant trends rest within a ticker can also allow you to adjust other indicators you use to the correct timeframe.           ///
/// For example, if you are using an EMA to scalp a specific ticker on the 1 minute timeframe, if there is a strong uptrend correlation                 ///
/// at 100 candles, it may be more appropriate to adjust your EMA to the 100 tf, as this is the tf with the most reliable trend.                        ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//@version=5
indicator("Trend Correlation Heatmap", shorttitle = "Trend Heatmap", overlay=true)

// User inputs 
timeframe1 = input.timeframe("1", "Timeframe One")  
timeframe2 = input.timeframe("5", "Timeframe Two") 
timeframe3 = input.timeframe("30", "Timeframe Three") 
timeframe4 = input.timeframe("1D", "Timeframe Four") 
showchange = input.bool(false, "Show Max and Min Change")
showlegend = input.bool(true, "Show Colour Legend") 

// Correlation 
f_correlation(timeframe, len) => 
    result = request.security(syminfo.ticker, timeframe, ta.correlation(close, time, len)) 

// Timeframe1 
cor1_50 = f_correlation(timeframe1, 50) 
cor1_100 = f_correlation(timeframe1, 100)
cor1_150 = f_correlation(timeframe1, 150) 
cor1_200 = f_correlation(timeframe1, 200)
cor1_250 = f_correlation(timeframe1, 250) 
cor1_300 = f_correlation(timeframe1, 300) 
cor1_350 = f_correlation(timeframe1, 350) 
cor1_400 = f_correlation(timeframe1, 400) 
cor1_450 = f_correlation(timeframe1, 450) 
cor1_500 = f_correlation(timeframe1, 500) 

// Timeframe2
cor5_50 = f_correlation(timeframe2, 50)
cor5_100 = f_correlation(timeframe2, 100)
cor5_150 = f_correlation(timeframe2, 150)
cor5_200 = f_correlation(timeframe2, 200)
cor5_250 = f_correlation(timeframe2, 250)
cor5_300 = f_correlation(timeframe2, 300)
cor5_350 = f_correlation(timeframe2, 350)
cor5_400 = f_correlation(timeframe2, 400)
cor5_450 = f_correlation(timeframe2, 450)
cor5_500 = f_correlation(timeframe2, 500)

// Timeframe3
cor30_50 = f_correlation(timeframe3, 50)
cor30_100 = f_correlation(timeframe3, 100)
cor30_150 = f_correlation(timeframe3, 150)
cor30_200 = f_correlation(timeframe3, 200)
cor30_250 = f_correlation(timeframe3, 250)
cor30_300 = f_correlation(timeframe3, 300)
cor30_350 = f_correlation(timeframe3, 350)
cor30_400 = f_correlation(timeframe3, 400)
cor30_450 = f_correlation(timeframe3, 450)
cor30_500 = f_correlation(timeframe3, 500)

// Timeframe4 
cor60_50 = f_correlation(timeframe4, 50)
cor60_100 = f_correlation(timeframe4, 100)
cor60_150 = f_correlation(timeframe4, 150)
cor60_200 = f_correlation(timeframe4, 200)
cor60_250 = f_correlation(timeframe4, 250)
cor60_300 = f_correlation(timeframe4, 300)
cor60_350 = f_correlation(timeframe4, 350) 
cor60_400 = f_correlation(timeframe4, 400)
cor60_450 = f_correlation(timeframe4, 450)
cor60_500 = f_correlation(timeframe4, 500)

// averages 
avg50 = math.avg(cor1_50, cor5_50, cor30_50, cor60_50) 
avg100 = math.avg(cor1_100, cor5_100, cor30_100, cor60_100)
avg150 = math.avg(cor1_150, cor5_150, cor30_150, cor60_150) 
avg200 = math.avg(cor1_200, cor5_200, cor30_200, cor60_200)
avg250 = math.avg(cor1_250, cor5_250, cor30_250, cor60_250)
avg300 = math.avg(cor1_300, cor5_300, cor30_300, cor60_300)
avg350 = math.avg(cor1_350, cor5_350, cor30_350, cor60_350) 
avg400 = math.avg(cor1_400, cor5_400, cor30_400, cor60_400)
avg450 = math.avg(cor1_450, cor5_450, cor30_450, cor60_450)
avg500 = math.avg(cor1_500, cor5_500, cor30_500, cor60_500)

// Min and Max 
cor1_max = math.max(cor1_50, cor1_100, cor1_150, cor1_200, cor1_250, cor1_300, cor1_350, cor1_400, cor1_450, cor1_500) 
cor1_min = math.min(cor1_50, cor1_100, cor1_150, cor1_200, cor1_250, cor1_300, cor1_350, cor1_400, cor1_450, cor1_500) 

cor5_max = math.max(cor5_50, cor5_100, cor5_150, cor5_200, cor5_250, cor5_300, cor5_350, cor5_400, cor5_450, cor5_500) 
cor5_min = math.min(cor5_50, cor5_100, cor5_150, cor5_200, cor5_250, cor5_300, cor5_350, cor5_400, cor5_450, cor5_500) 

cor30_max = math.max(cor30_50, cor30_100, cor30_150, cor30_200, cor30_250, cor30_300, cor30_350, cor30_400, cor30_450, cor30_500)
cor30_min = math.min(cor30_50, cor30_100, cor30_150, cor30_200, cor30_250, cor30_300, cor30_350, cor30_400, cor30_450, cor30_500)

cor60_max = math.max(cor60_50, cor60_100, cor60_150, cor60_200, cor60_250, cor60_300, cor60_350, cor60_400, cor60_450, cor60_500)
cor60_min = math.min(cor60_50, cor60_100, cor60_150, cor60_200, cor60_250, cor60_300, cor60_350, cor60_400, cor60_450, cor60_500)

total_max = math.max(cor1_50, cor1_100, cor1_150, cor1_200, cor1_250, cor1_300, cor1_350, cor1_400, cor1_450, cor1_500, cor5_50, cor5_100, cor5_150, cor5_200, cor5_250, cor5_300, cor5_350, cor5_400, cor5_450, cor5_500, cor30_50, cor30_100, cor30_150, cor30_200, cor30_250, cor30_300, cor30_350, cor30_400, cor30_450, cor30_500, cor60_50, cor60_100, cor60_150, cor60_200, cor60_250, cor60_300, cor60_350, cor60_400, cor60_450, cor60_500)
total_min = math.min(cor1_50, cor1_100, cor1_150, cor1_200, cor1_250, cor1_300, cor1_350, cor1_400, cor1_450, cor1_500, cor5_50, cor5_100, cor5_150, cor5_200, cor5_250, cor5_300, cor5_350, cor5_400, cor5_450, cor5_500, cor30_50, cor30_100, cor30_150, cor30_200, cor30_250, cor30_300, cor30_350, cor30_400, cor30_450, cor30_500, cor60_50, cor60_100, cor60_150, cor60_200, cor60_250, cor60_300, cor60_350, cor60_400, cor60_450, cor60_500)

// Colour Function
f_colour(variable, totalmax, totalmin, max, min) =>
    color green = color.lime 
    color red = color.red 
    color orange = color.orange 
    color yellow = color.yellow 
    color purple = color.purple
    color aqua = color.aqua 
    color blackfill = color.rgb(0, 0, 0) 


    variable == totalmax and variable >= 0.5 ? purple : variable == totalmin and variable <= -0.5 ? aqua : variable == max and variable >= 0.5 ? green : variable == min and variable <= -0.5 ? red : variable <= -0.5 and variable >= -1 ? orange : variable >= 0.5 and variable <= 1 ? yellow : blackfill

f_text_colour(variable, max, min) => 
    color purple = color.purple 
    color black = color.rgb(0, 0, 0) 
    color white = color.white
    variable == max and variable >= 0.5 ? white : variable == min and variable <= -0.5 ? white : variable <= -0.5 and variable >= -1 ? black : variable >= 0.5 and variable <= 1 ? black : white

// Table Colours 
color black =   color.rgb(0, 0, 0) 
color white =   color.white 

// Legend Colours 
color green =   color.lime 
color red =     color.red 
color orange =  color.orange 
color yellow =  color.yellow 
color purple =  color.purple
color aqua =    color.aqua 

var trendtable = table.new(position.top_right, 10, 12, bgcolor = black) 

table.cell(trendtable, 1, 1, text = "Length", bgcolor = black, text_color=white) 
table.cell(trendtable, 2, 1, text = str.tostring(timeframe1), bgcolor = black, text_color=white) 
table.cell(trendtable, 3, 1, text = str.tostring(timeframe2), bgcolor = black, text_color=white) 
table.cell(trendtable, 4, 1, text = str.tostring(timeframe3), bgcolor = black, text_color=white) 
table.cell(trendtable, 5, 1, text = str.tostring(timeframe4), bgcolor = black, text_color=white) 
table.cell(trendtable, 6, 1, text = "Average", bgcolor = black, text_color=white) 
// Reference
table.cell(trendtable, 1, 2, text = "50", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 3, text = "100", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 4, text = "150", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 5, text = "200", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 6, text = "250", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 7, text = "300", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 8, text = "350", bgcolor = black, text_color=white) 
table.cell(trendtable, 1, 9, text = "400", bgcolor = black, text_color=white)
table.cell(trendtable, 1, 10, text = "450", bgcolor = black, text_color=white)
table.cell(trendtable, 1, 11, text = "500", bgcolor = black, text_color=white)
// 1 minute
table.cell(trendtable, 2, 2, text = str.tostring(math.round(cor1_50, 2)), bgcolor=f_colour(cor1_50, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_50, cor1_max, cor1_min))
table.cell(trendtable, 2, 3, text = str.tostring(math.round(cor1_100, 2)), bgcolor=f_colour(cor1_100, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_100, cor1_max, cor1_min))
table.cell(trendtable, 2, 4, text = str.tostring(math.round(cor1_150, 2)), bgcolor=f_colour(cor1_150, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_150, cor1_max, cor1_min))
table.cell(trendtable, 2, 5, text = str.tostring(math.round(cor1_200, 2)), bgcolor=f_colour(cor1_200, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_200, cor1_max, cor1_min))
table.cell(trendtable, 2, 6, text = str.tostring(math.round(cor1_250, 2)), bgcolor=f_colour(cor1_250, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_250, cor1_max, cor1_min))
table.cell(trendtable, 2, 7, text = str.tostring(math.round(cor1_300, 2)), bgcolor=f_colour(cor1_300, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_300, cor1_max, cor1_min))
table.cell(trendtable, 2, 8, text = str.tostring(math.round(cor1_350, 2)), bgcolor=f_colour(cor1_350, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_350, cor1_max, cor1_min))
table.cell(trendtable, 2, 9, text = str.tostring(math.round(cor1_400, 2)), bgcolor=f_colour(cor1_400, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_400, cor1_max, cor1_min))
table.cell(trendtable, 2, 10, text = str.tostring(math.round(cor1_450, 2)), bgcolor=f_colour(cor1_450, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_450, cor1_max, cor1_min))
table.cell(trendtable, 2, 11, text = str.tostring(math.round(cor1_500, 2)), bgcolor=f_colour(cor1_500, total_max, total_min, cor1_max, cor1_min), text_color=f_text_colour(cor1_500, cor1_max, cor1_min))
// 5 Minute
table.cell(trendtable, 3, 2, text = str.tostring(math.round(cor5_50, 2)), bgcolor=f_colour(cor5_50, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor5_50, cor5_max, cor5_min))
table.cell(trendtable, 3, 3, text = str.tostring(math.round(cor5_100, 2)), bgcolor=f_colour(cor5_100, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_100, cor5_max, cor5_min))
table.cell(trendtable, 3, 4, text = str.tostring(math.round(cor5_150, 2)), bgcolor=f_colour(cor5_150, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_150, cor5_max, cor5_min))
table.cell(trendtable, 3, 5, text = str.tostring(math.round(cor5_200, 2)), bgcolor=f_colour(cor5_200, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_200, cor5_max, cor5_min))
table.cell(trendtable, 3, 6, text = str.tostring(math.round(cor5_250, 2)), bgcolor=f_colour(cor5_250, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_250, cor5_max, cor5_min))
table.cell(trendtable, 3, 7, text = str.tostring(math.round(cor5_300, 2)), bgcolor=f_colour(cor5_300, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_300, cor5_max, cor5_min))
table.cell(trendtable, 3, 8, text = str.tostring(math.round(cor5_350, 2)), bgcolor=f_colour(cor5_350, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_350, cor5_max, cor5_min))
table.cell(trendtable, 3, 9, text = str.tostring(math.round(cor5_400, 2)), bgcolor=f_colour(cor5_400, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_400, cor5_max, cor5_min))
table.cell(trendtable, 3, 10, text = str.tostring(math.round(cor5_450, 2)), bgcolor=f_colour(cor5_450, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_450, cor5_max, cor5_min))
table.cell(trendtable, 3, 11, text = str.tostring(math.round(cor5_500, 2)), bgcolor=f_colour(cor5_500, total_max, total_min, cor5_max, cor5_min), text_color=f_text_colour(cor5_500, cor5_max, cor5_min))
// 30 Minute
table.cell(trendtable, 4, 2, text = str.tostring(math.round(cor30_50, 2)), bgcolor=f_colour(cor30_50, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_50, cor30_max, cor30_min))
table.cell(trendtable, 4, 3, text = str.tostring(math.round(cor30_100, 2)), bgcolor=f_colour(cor30_100, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_100, cor30_max, cor30_min))
table.cell(trendtable, 4, 4, text = str.tostring(math.round(cor30_150, 2)), bgcolor=f_colour(cor30_150, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_150, cor30_max, cor30_min))
table.cell(trendtable, 4, 5, text = str.tostring(math.round(cor30_200, 2)), bgcolor=f_colour(cor30_200, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_200, cor30_max, cor30_min))
table.cell(trendtable, 4, 6, text = str.tostring(math.round(cor30_250, 2)), bgcolor=f_colour(cor30_250, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_250, cor30_max, cor30_min))
table.cell(trendtable, 4, 7, text = str.tostring(math.round(cor30_300, 2)), bgcolor=f_colour(cor30_300, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_300, cor30_max, cor30_min))
table.cell(trendtable, 4, 8, text = str.tostring(math.round(cor30_350, 2)), bgcolor=f_colour(cor30_350, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_350, cor30_max, cor30_min))
table.cell(trendtable, 4, 9, text = str.tostring(math.round(cor30_400, 2)), bgcolor=f_colour(cor30_400, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_400, cor30_max, cor30_min))
table.cell(trendtable, 4, 10, text = str.tostring(math.round(cor30_450, 2)), bgcolor=f_colour(cor30_450, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_450, cor30_max, cor30_min))
table.cell(trendtable, 4, 11, text = str.tostring(math.round(cor30_500, 2)), bgcolor=f_colour(cor30_500, total_max, total_min, cor30_max, cor30_min), text_color=f_text_colour(cor30_500, cor30_max, cor30_min))
// 1 hour 
table.cell(trendtable, 5, 2, text = str.tostring(math.round(cor60_50, 2)), bgcolor=f_colour(cor60_50, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_50, cor60_max, cor60_min))
table.cell(trendtable, 5, 3, text = str.tostring(math.round(cor60_100, 2)), bgcolor=f_colour(cor60_100, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_100, cor60_max, cor60_min))
table.cell(trendtable, 5, 4, text = str.tostring(math.round(cor60_150, 2)), bgcolor=f_colour(cor60_150, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_150, cor60_max, cor60_min))
table.cell(trendtable, 5, 5, text = str.tostring(math.round(cor60_200, 2)), bgcolor=f_colour(cor60_200, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_200, cor60_max, cor60_min))
table.cell(trendtable, 5, 6, text = str.tostring(math.round(cor60_250, 2)), bgcolor=f_colour(cor60_250, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_250, cor60_max, cor60_min))
table.cell(trendtable, 5, 7, text = str.tostring(math.round(cor60_300, 2)), bgcolor=f_colour(cor60_300, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_300, cor60_max, cor60_min))
table.cell(trendtable, 5, 8, text = str.tostring(math.round(cor60_350, 2)), bgcolor=f_colour(cor60_350, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_350, cor60_max, cor60_min))
table.cell(trendtable, 5, 9, text = str.tostring(math.round(cor60_400, 2)), bgcolor=f_colour(cor60_400, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_400, cor60_max, cor60_min))
table.cell(trendtable, 5, 10, text = str.tostring(math.round(cor60_450, 2)), bgcolor=f_colour(cor60_450, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_450, cor60_max, cor60_min))
table.cell(trendtable, 5, 11, text = str.tostring(math.round(cor60_500, 2)), bgcolor=f_colour(cor60_500, total_max, total_min, cor60_max, cor60_min), text_color=f_text_colour(cor60_500, cor60_max, cor60_min))
// Average
table.cell(trendtable, 6, 2, text = str.tostring(math.round(avg50, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 3, text = str.tostring(math.round(avg100, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 4, text = str.tostring(math.round(avg150, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 5, text = str.tostring(math.round(avg200, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 6, text = str.tostring(math.round(avg250, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 7, text = str.tostring(math.round(avg300, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 8, text = str.tostring(math.round(avg350, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 9, text = str.tostring(math.round(avg400, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 10, text = str.tostring(math.round(avg450, 2)), bgcolor=black, text_color=white)
table.cell(trendtable, 6, 11, text = str.tostring(math.round(avg500, 2)), bgcolor=black, text_color=white)


// Strongest and Weaknest 

total_max_change = ta.change(total_max, 14) 
total_min_change = ta.change(total_min, 14) 

var datatable = table.new(position.bottom_right, 3, 9, bgcolor = black) 
if showchange
    table.cell(datatable, 1, 1, text = "Max Change:", bgcolor = black, text_color = total_max_change > 0 ? green : red) 
    table.cell(datatable, 2, 1, text = str.tostring(math.round(total_max_change,4)), bgcolor = black, text_color = total_max_change > 0 ? green: red) 
    table.cell(datatable, 1, 2, text = "Min Change:", bgcolor = black, text_color = total_min_change > 0 ? green : red) 
    table.cell(datatable, 2, 2, text = str.tostring(math.round(total_min_change,4)), bgcolor = black, text_color = total_min_change > 0 ? green : red) 
if showlegend  
    table.cell(datatable, 1, 3, text = "Strongest Overall Uptrend", bgcolor = black, text_color = white) 
    table.cell(datatable, 2, 3, text = "         ", bgcolor = purple)
    table.cell(datatable, 1, 4, text = "Strongest Overall Downtrend", bgcolor = black, text_color=white) 
    table.cell(datatable, 2, 4, text = "         ", bgcolor = aqua)
    table.cell(datatable, 1, 5, text = "Strongest Uptrend (per timeframe)", bgcolor = black, text_color=white) 
    table.cell(datatable, 2, 5, text = "         ", bgcolor = green)
    table.cell(datatable, 1, 6, text = "Strongest Downtrend (per timeframe)", bgcolor = black, text_color=white) 
    table.cell(datatable, 2, 6, text = "         ", bgcolor = red)
    table.cell(datatable, 1, 7, text = "Significant Uptrend (per timeframe)", bgcolor = black, text_color=white)
    table.cell(datatable, 2, 7, text = "         ", bgcolor = yellow, text_color=white)
    table.cell(datatable, 1, 8, text = "Significant Downtrend (per timeframe)", bgcolor = black, text_color=white)
    table.cell(datatable, 2, 8, text = "         ", bgcolor = orange, text_color=white)
````
