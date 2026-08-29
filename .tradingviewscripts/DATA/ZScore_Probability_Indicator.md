<!-- tradingview-pine-id: PUB;90119358b79349dd8c1ca01b8e5d8baa -->
<!-- tradingviewscripts-format: 1 -->
# Z-Score Probability Indicator

Source: https://www.tradingview.com/script/zrc6tWT4-Z-Score-Probability-Indicator/

## Description

This is the Z-Score Probability indicator. As many people like my original Z-Score indicator and have expressed more interest in the powers of the Z, I decided to make this indicator which shows additional powers of the Z-Score. 

Z-Score is not only useful for measuring a ticker or any other variable’s distance from the mean, it is also useful to calculate general probability in a normal distribution set. Not only can it calculate probability in a dataset, but it can also calculate the variables within said dataset by using the Standard Deviation and the Mean of the dataset. 

Using these 2 aspects of the Z-Score, you can, In principle, have an indicator that operates similar to Fibonacci retracement levels with the added bonus of being able to actually ascertain the realistic probability of said retracement. 

Let’s take a look at an example: 

https://www.tradingview.com/x/PbQp7em6/

This is a chart showing SPY on the daily timeframe. If we look at the current Z-Score level, we can see that SPY is pushing into the 2 to 3 Z-Score range. We can see two things from this:

1.	We can see that a retracement to a Z-Score of 2 would correspond to a price of 425.26 based on the current dataset. And 
2.	We can see that the probability that SPY retraces to a Z-Score of 2 is around 0.9800 or 98%. 

To take it one step further, we can look at the various other variables in the distribution. If we were to bet on SPY retracing back to -1 SDs, that would correspond to a price of around 397.15, with a probability of around 0.1600 or 16% (see image below): 

https://www.tradingview.com/x/zQBZP3Ij/

Let’s say, we thought SPY would go to $440. Well, we can see that the probability SPY goes to 434.64 currently is pretty low. How do we know? Because the Z-Score table shows us the probability of values falling BELOW that Z-score level in the current distribution. So if we look at this example below:
https://www.tradingview.com/x/dWF0tBHk/

We can see that 0.9998 or roughly 99% of values in the current SPY distribution will fall below 434.64. Thus, it may be unrealistic, at this point in time, to target said value.  

So what is a Z-Score Table? 

Well, I need to disclose/clarify that the Z-Score Table being displayed in this indicator does Z-Score probability a HUGE injustice. However, with the constraints what is realistic to fit into an indicator, I had to make it far more succinct. Let’s take a look at an actual Z-Score Table below:

https://www.tradingview.com/x/G4ed6pPE/

Above is a look an the actual Z-Score table. How it works is you first identify you’re Z-Score and then find the corresponding value that relates to your score. The number displayed in the dataset represents the number of variables in the dataset/density distribution that fall BELOW that particular Z-score.
So, for example, if we have a Z-Score of -2.31, we can consult that table, go to the -2.3 then scroll across to the 0.01 to represent -2.31. We would see that this Z-Score corresponds to a 0.0104 probability zone (or essentially 1%) indicating that the majority of the variables in the distribution fall below that mean Z-score. In terms of tickers and stocks, that would mean it would theoretically be “overbought”. 

So what does the indicator Z-Table tell us?

I have averaged out the data for the purposes of this indicator. However, you can also reference a manual Z-Table to get the exact probability for the current precise Z-Score. However, the reality is it doesn’t necessarily matter to be exact when it comes to tickers. The reason being, ticker’s are in constant flux, and by the time you identify that probability, the ticker will already be at a different level. So generalizations are okay in these circumstances, you just need to get the “gist” of where the distribution lies. 

So how do I use the indicator? 

Using the indicator is pretty straightforward. Once launched, you will see the current Z-Score of the ticker, the current levels based on the distribution and the summarized Z-Table. 

The Z-Table will turn gray to indicate the zone the ticker is currently in. In this case, we can see that SPY currently is in the 2 SD Zone, meaning that 0.98 or 98% of the current dataset being shown falls below the price we are at:

https://www.tradingview.com/x/xOmZXwmj/

When we launch the settings, we can see a few inputs. 

https://www.tradingview.com/x/7mLhrsFd/

Lookback Length: This determines the number of candles back we want to calculate the distribution for. It is defaulted to 75, but you can adjust it to whichever length you want.

SMA Length: The SMA is optional but defaults to on. If you want to see the smoothed trend of the Z-Score, this will do the trick. It does not need to be set to the same 
length as the Z-Score lookback. Thus, if you want a more or less responsive SMA with, say, a larger dataset, then you can reduce the SMA length yourself. 

Distribution Probability Fills: This simply colour codes the distribution zones / probability zones on the indicator. 

Show Z-Table: This will display the summarized Z-Table.

Show SMA: As I indicated, the SMA is optional, you can toggle it on or off to see the overall Z-Score trend. 

Concluding Remarks: 

And that my friends is the Z-Score Probability Indicator.
I hope you all enjoy it and find it helpful. As always leave your comments, questions and suggestions below.

Safe trades to all and take care!

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

//@version=5
indicator("Z-Score Probability Indicator")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            Tooltips                                                                                 ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

t1 = "Determines the Length of Z-Score Assessment. Defaults to a 75 lookback period" 
t2 = "Determines the length of the SMA if the user selects Show SMA. Default is 75, but for a more responsive SMA you can reduce it to 14. Optional."
t3 = "Shows the probability zones in colour." 
t4 = "Will Display a summarized Z-Table." 
t5 = "Display's the SMA."  

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            User Inputs                                                                              ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
len = input.int(75, "Lookback Length", tooltip=t1)
plot_type = input.string("Area", "Plot Type", ["Area", "Candles"])
txtcolor = input.string("White", "Text Colour", ["White", "Black", "Blue"])
smalen = input.int(75, "SMA Length", tooltip=t2) 
probfill = input.bool(true, "Distribution Probaiblity Fills", tooltip=t3) 
showztable = input.bool(true, "Show Z-Table", tooltip=t4) 
showsma = input.bool(true, "Show SMA", tooltip=t5) 
showsd = input.bool(false, "Show SMA Standard Deviation Bands")
roundup = input.int(2, "Round Target Prices Up or Down")
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            Z-Score/SMA Calculations                                                                  ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
z = (close - ta.sma(close, len)) / ta.stdev(close, len) 
z_hi = (high - ta.sma(high, len)) / ta.stdev(high, len) 
z_lo = (low - ta.sma(low, len)) / ta.stdev(low, len) 
z_op = (open - ta.sma(open, len)) / ta.stdev(open, len) 

float z_close = 0.0
float z_open = 0.0 
float z_high = 0.0 
float z_low = 0.0 

if plot_type == "Candles"
    z_close := z 
    z_high := z_hi
    z_low :=z_lo
    z_open := z_op 

cl_sma = ta.sma(close, len) 
cl_sd = ta.stdev(close, len) 

// SMA 
var float z_sma = 0.0 

if showsma 
    z_sma := ta.sma(z, smalen) 
sma_sd_bands = ta.stdev(z_sma, smalen) 
plot(showsd ? z_sma + sma_sd_bands : na, "SMA UCL Bands", color = color.aqua)
plot(showsd ? z_sma - sma_sd_bands : na, "SMA LCL Bands", color = color.aqua)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                           Colours                                                                                  ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
color red = color.red 
color green = color.green 
color orange = color.orange 
color yellow = color.yellow 
color labelcolor = color.new(color.white, 100) 
color gray = color.new(color.gray, 25) 
color white = color.white 
color black = color.rgb(0, 0, 0) 
color blue = color.blue 
// Colour for Probability Distribution 
color greenfill = color.new(color.green, 75) 
color yellowfill = color.new(color.yellow, 75) 
color redfill = color.new(color.red, 75) 
color candlecolor = z_op > z ? color.red : z > z_op ? color.lime : color.lime 

plotcandle(z_open, z_high, z_low, z_close, "Candles", color = candlecolor) 
f_txtcolor(string) => 
    if string == "White" 
        color = white 
    else if string =="Black" 
        color = black
    else if string == "Blue"
        color = blue  

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            Logical Assessments                                                                      ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool zero_one = z >= 0 and z < 1 
bool one_two = z >= 1 and z < 2.01 
bool two_three = z >= 2 and z < 3.01 
bool three = z >= 3 
bool zero = z >= 0.99 and z <= -0.99 
bool neg_zero_one = z < 0 and z > -1 
bool neg_one_two = z <= -1 and z > -2 
bool neg_two_three = z <= -2 and z > -3 
bool neg_three = z <= -3 
falling = ta.falling(z_sma, 3) 
rising = ta.rising(z_sma, 3) 


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                         Plots                                                                                        ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
color z_color_plot = z > 0 ? green : z <= 0 ? red : orange 
plot(plot_type == "Area" ? z : na, "Z-Score", color=z_color_plot, style=plot.style_area) 
plot(z_sma, "Z-SMA", color=showsma ? white : labelcolor, linewidth=2) 

neutral = 0 
onesd = 1 
twosd = 2 
threesd = 3 
neg_onesd = -1 
neg_twosd = -2 
neg_threesd = -3 

a = plot(neutral, color=greenfill)  
b = plot(onesd, color=yellowfill)  
c = plot(twosd, color=redfill) 
d = plot(threesd, color=redfill)  
e = plot(neg_onesd, color=greenfill)  
f = plot(neg_twosd, color=yellowfill) 
g = plot(neg_threesd, color=redfill) 

fill(a, b, color=probfill ? greenfill : na) 
fill(b, c, color=probfill ? yellowfill : na) 
fill(c, d, color=probfill ? redfill : na) 
fill(a, e, color=probfill ? greenfill : na) 
fill(e, f, color=probfill ? yellowfill : na) 
fill(f, g, color=probfill ? redfill : na) 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                           Price Level Calculations                                                                  ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

neutral_price = (cl_sma) + (0 * cl_sd) 
onesd_price = (cl_sma) + (1 * cl_sd) 
twosd_price = (cl_sma) + (2 * cl_sd) 
threesd_price = (cl_sma) + (3 * cl_sd) 
neg_onesd_price = (cl_sma) + (-1 * cl_sd) 
neg_twosd_price = (cl_sma) + (-2 * cl_sd) 
neg_threesd_price = (cl_sma) + (-3 * cl_sd) 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            Line Plots                                                                              ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


var label neutral_price_line = na 
var label onesd_price_line = na
var label twosd_price_line = na 
var label threesd_price_line = na 
var label neg_onesd_price_line = na 
var label neg_twosd_price_line = na 
var label neg_threesd_price_line = na


if bar_index >= 75 
    label.delete(neutral_price_line) 
    label.delete(onesd_price_line) 
    label.delete(twosd_price_line)
    label.delete(threesd_price_line) 
    label.delete(neg_onesd_price_line) 
    label.delete(neg_twosd_price_line)
    label.delete(neg_threesd_price_line) 
    neutral_price_line := label.new(bar_index, y=neutral, text=str.tostring(math.round(neutral_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor = f_txtcolor(txtcolor), size=size.large, textalign = text.align_right)
    onesd_price_line := label.new(bar_index - 5, onesd, str.tostring(math.round(onesd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor = f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 
    twosd_price_line := label.new(bar_index - 5, twosd, str.tostring(math.round(twosd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor =  f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 
    threesd_price_line := label.new(bar_index - 5, threesd, str.tostring(math.round(threesd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor =  f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 
    neg_onesd_price_line := label.new(bar_index - 5, neg_onesd, str.tostring(math.round(neg_onesd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor =  f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 
    neg_twosd_price_line := label.new(bar_index - 5, neg_twosd, str.tostring(math.round(neg_twosd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor =  f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 
    neg_threesd_price_line := label.new(bar_index - 5, neg_threesd, str.tostring(math.round(neg_threesd_price,roundup)), color=labelcolor, style=label.style_label_left, textcolor =  f_txtcolor(txtcolor), size=size.large, textalign = text.align_right) 


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                                                            Z-Table                                                                                 ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

var ztable = table.new(position.bottom_center, 10, 3, bgcolor = color.white) 

if showztable 
    // Z-Score / Columns 
    table.cell(ztable, 1, 1, text="Z-Score:", bgcolor = color.white, text_color = color.black) 
    table.cell(ztable, 2, 1, text = "-3", bgcolor = neg_three ? gray : white, text_color=color.black) 
    table.cell(ztable, 3, 1, text="-2", bgcolor = neg_two_three ? gray : white, text_color = color.black) 
    table.cell(ztable, 4, 1, text="-1", bgcolor = neg_zero_one ? gray : white, text_color=color.black) 
    table.cell(ztable, 5, 1, text="0", bgcolor= zero ? gray : white, text_color=color.black) 
    table.cell(ztable, 6, 1, text="1", bgcolor=zero_one ? gray : white, text_color=color.black) 
    table.cell(ztable, 7, 1, text="2", bgcolor=two_three ? gray : white, text_color=color.black) 
    table.cell(ztable, 8, 1, text="3", bgcolor=three ? gray : white, text_color=color.black) 
    // Probability / Rows 
    table.cell(ztable, 1, 2, text="Probability:", bgcolor = color.white, text_color = color.black) 
    table.cell(ztable, 2, 2, text = "0.0013", bgcolor = red, text_color=color.black) 
    table.cell(ztable, 3, 2, text="0.0228", bgcolor = yellow, text_color = color.black) 
    table.cell(ztable, 4, 2, text="0.1600", bgcolor = green, text_color=color.black) 
    table.cell(ztable, 5, 2, text="0.5000", bgcolor=green, text_color=color.black) 
    table.cell(ztable, 6, 2, text="0.8500", bgcolor=green, text_color=color.black) 
    table.cell(ztable, 7, 2, text="0.9800", bgcolor=yellow, text_color=color.black) 
    table.cell(ztable, 8, 2, text="0.9998", bgcolor=red, text_color=color.black)
````
