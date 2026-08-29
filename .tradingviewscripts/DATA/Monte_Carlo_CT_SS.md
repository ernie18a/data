<!-- tradingview-pine-id: PUB;7e7d3fed2d9c4408bd6da7818dc48fd4 -->
<!-- tradingviewscripts-format: 1 -->
# Monte Carlo CT [SS]

Source: https://www.tradingview.com/script/9q1VcIPG-Monte-Carlo-CT-SS/

## Description

This is the Monte Carlo CT indicator. 
CT stands for "central tendencies" and is the real distinguishing characteristic of this indicator against other Monte Carlo based indicators. 

In statistics, Central Tendency is a single value that attempts to describe a set of data by identifying the central position within that set. It is the typical or expected value that the data clusters around. While the most common measures are the mean (average), median (middle value), and mode (most frequent), in a Monte Carlo simulation, the central tendency acts as the gravity points of the forecast. Because a random walk can technically produce infinite paths, with some shooting to the moon and others crashing to zero, the central tendency filters out those wild outliers to show you the most mathematically probable path forward.

Instead of looking at the chaos of 200 individual spaghetti lines, the central tendency condenses that massive dataset into a clean, usable trajectory. It essentially represents the path of least resistance based on the historical volatility and drift the model has identified. By focusing on the median and its surrounding percentiles, you are shifting your perspective from "What could happen?" to "What is likely to happen?"

Now that we have that cleared up, lets talk more about the indicator and its components. 

The Core Engine: Anchored Monte Carlo

Traditional Monte Carlo simulations often generate a spaghetti chart of thousands of lines that are visually overwhelming and practically unusable for a trader.

As we discussed above, this indicator uses Central Tendencies to solve that. Instead of showing every random path, it runs the simulations in the background and only plots the distribution percentiles.

Why Central Tendency > Raw Simulations?

The Median (White Line): Represents the average outcome. If you ran these simulations infinitely, this is the center of the bell curve.

The 75/25 Zones (Solid Green/Red): These are the standard volatility bounds. Price spent 50% of its simulated time within this corridor.

The 95/05 Bounds (Dashed Green/Red): These represent "Statistical Extremes." If price reaches these levels, it is entering a 2-sigma move (an outlier event).

The introduction of Naive Bayes 
While everyone obsesses over KNN, I decided to do a little curve ball and try something new, most notably Naive Bayes. 

While Monte Carlo is blind to current sentiment (it only cares about volatility and average returns), implementing a Naive Bayes Classifier allows the indicator to be highly observant. It looks at the relative volume and momentum to determine if the current bar looks like a winner or a loser based on the last x bars of training data.

Interpreting the Table
The NB Analysis table in the top right is your tactical dashboard:

Win Prob: This is the Posterior Probability. It’s the calculated likelihood that the current market conditions will lead to a positive price move.

Example: 65% means the training data of the current volume and momentum is historically skewed toward bulls.

MC Median: This pulls the final price point from the white Monte Carlo line. It gives you a specific price target for the end of your forecast horizon.

Rel Volume: Shows how much effort the market is putting in compared to its 50-period average. High volume + high Win Prob is a high-conviction signal.

Signal (LONG/SHORT): A binary output. If Win Prob > 50%, it flips to LONG.

Confidence: This filters the noise. If the Win Prob is between 40% and 60%, the model is essentially tossing a coin (Moderate). If it hits >70% or <30%, the statistical evidence is strong (High).

Using this tool 

Ah yes, the practicality. Boring but important. 

The most effective way to use this tool is to look for Convergence:

[*] Check the Table: Is the Signal "LONG" with "HIGH" Confidence?
[*] Check the Forecast: Does the Monte Carlo Median (White Line) have an upward slope?
[*] Execute: Use the 25% (Solid Red) or 05% (Dashed Red) lines as buy the dip zones within a bullish forecast. Conversely, use the 95% (Dashed Green) as a logical place to take profits or tighten stops.

Customizations 
In the user settings menu, you can adjust: 

[*] The lookback or training length for the Monte Carlo Simulations 
[*] The forecast length 
[*] The training length for the Naive Bayes model 

Some general tips are: 

[*] Make sure your lookback is the same size or larger than your forecast 
[*] Match the forecast length with your trading horizon. If you want to be in no more than 1 hour on the 1-Minute chart, make sure you are setting this for a forecast horizon of 60 candles. 

The Cherry on Top
In professional quantitative finance, we don't just guess; we model. This indicator uses a Log Normal Random Walk for the Monte Carlo and a Gaussian PDF (Probability Density Function) for the Naive Bayes, bringing institutional-grade math to the Pine Script environment. It treats trading as a game of probabilities, not certainties.

And there you have it! Hopefully you find this helpful and enjoy. 
Thanks for reading and checking it out!

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steversteves
//                                                                                                
//                                                           =                                        
//                            ≈×  ≠±                          ≠≤    ≠:   ≈                            
//                           ≤≠  ≥≈                            ≠∑   ≈≥   ≈≥                           
//                       ≈   ≤∑ √≠=  =>             .           ≈≥:  ∑≈  ∑≠                           
//                       ∑   ≥∑≥√±  ≥≈           :>Iii;.         ≈≤≥ ≥±  ≥±  =                        
//                       ≥∑   ∑∑≠× ≤≈           ->IIii,:;         ±≤∑∑± √×   ≥÷                       
//                       ≥≥∑   ≥≥= ≥=          ->IIIi;   :!i,      ∑≥≤×∑±×   ≤-                       
//                        ≥≥∑  ∑≥≥√=.         <-<IIII; .    ,   ≥≠  ∑≈≥≈÷   √≠                        
//                         ≈≥∑≈ ≤∑≈+  ÷       -IIIIi;i: l       ≥≥= ∑≤±=   ∑≠                         
//                       =≥  ≤≥≤ ≥≈  ≈≤×     !::iii;::  .:      ∑≤ √∑+   ≠≥÷l                         
//                        ≈≥≥= ≠≤≥≠∑  ≥≥     iii;,.  .   >      ≥±=√± √≥≈-+                           
//                          ≈≈≤∑√≤≠≠≥∑≠≤≥   .,;!!Ii;;:,   l    ≥≠∑≥≈×+>>:                             
//                             :+<!!!<>×÷≈=!<iiii;;;;;;i:  .!==><+×+                                  
//                                      ,iI!;.           .,ii,                                        
//                                ;iIII;.    ∂-∇⋆•∇⋆⋆∇√>>:    ,iiIi:,                                 
//                                 I,      : ≥  +∇∫•≥<  !  :      ,:                                  
//                                   ;I:   : °:I≠≥∑⋆≤-  =, :    ;,                                    
//                                        I   <∂•°∂•≤÷×I  , ;                                         
//                                       :.:   ≈•∇≠≥∑÷+    ; ,                                        
//                                       ;....  ∇I, ≠-   ;  ,                                         
//                                          <:i ∇⋆°∏∂+  : ; : .                                       
//                                      I;. Il.:≥∇∏±+< ;:.    :i                                      
//                                  :<l: I.. !II.      ,i   . ,  ,!I                                  
//                                 ilIIIi ;.  >!,,:;, : ;  ,.      .<                                 
//                                 !IiI;II: ; :.!Iii:,;   ;.  ,i.   .i                                
//                                !I,;Ii iii    ,<i::i. ,,  iii      l                                
//                                II ,i;; ,i,;   Il.:     i;i,     :  I                               
//                               i,.  ; ;:  ;. .  l..   ;, :   ,   :  .                               
//                                       .:        ,   .      ,.                                      
//                               iI   i;;IIIi IIi  ,I   .I.i;  i;  .=±+;                              
//                               ∂∂÷ ≥∂÷×∫!!! ∂i ≈∇>∇   :∂.√∇∫,∑× I∂-i,!.                             
//                               ≈I±≈-÷+>±... ≈×±≈,l≠   ,≠.≈=!≠≠> . ,;>≈l                             
//                               I: I i;;IIII I, ;I;IIII.I.Ii  I; .I<><I                              
                                                                                         //@version=6
indicator("Monte Carlo CT [SS]", overlay = true, max_polylines_count = 10, max_labels_count = 10)

// User inputs 
grp_mc   = "Monte Carlo Settings"
sims     = input.int(200, "Simulations", minval = 10, maxval = 500, group = grp_mc)
forx     = input.int(50,  "Forecast Horizon", minval = 2, maxval = 500, group = grp_mc)
back     = input.int(200, "Historical Lookback", group = grp_mc)
showtbl  = input.bool(true, "Show Naive Bayes Table", group = grp_mc)
grp_nb   = "Naive Bayes Settings"
nb_train = input.int(500, "NB Train Lookback", group = grp_nb)

// Colours 
pal_neon_bull = #00ffcc 
pal_neon_bear = #ff00ff

// PDF function for distribution 
f_pdf(x, mean, variance) => 
    float v = math.max(variance, 0.000001)
    (1 / math.sqrt(2 * math.pi * v)) * math.exp(-math.pow(x - mean, 2) / (2 * v))

//Data 
var float[] returns = array.new_float()
if last_bar_index - bar_index <= back
    returns.push(math.log(close / close[1]))

// Vola and Mom 
float rel_vol  = nz(volume / ta.sma(volume, 50), 1.0)
float momentum = ta.roc(close, 10)
target = close > close[1] ? 1 : 0

m1_f1 = ta.sma(target > 0 ? rel_vol : na, nb_train), m1_f2 = ta.sma(target > 0 ? momentum : na, nb_train)
m0_f1 = ta.sma(target <= 0 ? rel_vol : na, nb_train), m0_f2 = ta.sma(target <= 0 ? momentum : na, nb_train)
v1_f1 = math.pow(ta.stdev(target > 0 ? rel_vol : na, nb_train), 2), v1_f2 = math.pow(ta.stdev(target > 0 ? momentum : na, nb_train), 2)
v0_f1 = math.pow(ta.stdev(target <= 0 ? rel_vol : na, nb_train), 2), v0_f2 = math.pow(ta.stdev(target <= 0 ? momentum : na, nb_train), 2)
p1 = nz(ta.sma(target > 0 ? 1.0 : 0.0, nb_train), 0.5)

l1 = f_pdf(rel_vol, nz(m1_f1), nz(v1_f1)) * f_pdf(momentum, nz(m1_f2), nz(v1_f2)) * p1
l0 = f_pdf(rel_vol, nz(m0_f1), nz(v0_f1)) * f_pdf(momentum, nz(m0_f2), nz(v0_f2)) * (1.0 - p1)
main_prob = nz(l1 / (l1 + l0 + 0.000001), 0.5)
main_sig  = main_prob > 0.5 ? 1 : 0

f_label(pt_array, txt, clr) =>
    last_pt = array.get(pt_array, array.size(pt_array) - 1)
    label.new(last_pt.index, last_pt.price, txt + ": " + str.tostring(last_pt.price, format.mintick), 
        color=color.new(color.black, 100), 
        textcolor=clr, 
        style=label.style_label_left, 
        size=size.small)


// MC 
get_percentile(array<float> arr, float p) =>
    array<float> sorted = arr.copy()
    sorted.sort()
    idx = math.floor(p * (sorted.size() - 1))
    sorted.get(idx)

if barstate.islastconfirmedhistory and returns.size() > 1
    results = matrix.new<float>(forx, sims, close)
    avg_ret = returns.avg(), std_ret = returns.stdev()

    for s = 0 to sims - 1
        float cur_p = close
        for t = 1 to forx - 1
            z = math.sqrt(-2.0 * math.log(math.random(0.01, 0.99))) * math.cos(2.0 * math.pi * math.random(0.01, 0.99))
            cur_p *= math.exp(avg_ret + std_ret * z)
            results.set(t, s, cur_p)


    p95 = array.new<chart.point>(), p75 = array.new<chart.point>(), p50 = array.new<chart.point>()
    p25 = array.new<chart.point>(), p05 = array.new<chart.point>()

    for t = 0 to forx - 1
        col = results.row(t)
        p95.push(chart.point.from_index(bar_index + t, get_percentile(col, 0.95)))
        p75.push(chart.point.from_index(bar_index + t, get_percentile(col, 0.75)))
        p50.push(chart.point.from_index(bar_index + t, get_percentile(col, 0.50)))
        p25.push(chart.point.from_index(bar_index + t, get_percentile(col, 0.25)))
        p05.push(chart.point.from_index(bar_index + t, get_percentile(col, 0.05)))

// Render Polylines (5 Total)
    polyline.new(p95, line_color = color.new(color.green, 0), line_width = 1, line_style = line.style_dashed)
    polyline.new(p75, line_color = color.new(color.green, 0), line_width = 2)
    polyline.new(p50, line_color = color.white,              line_width = 3) // Median
    polyline.new(p25, line_color = color.new(color.red, 0),   line_width = 2)
    polyline.new(p05, line_color = color.new(color.red, 0),   line_width = 1, line_style = line.style_dashed)



    f_label(p95, "95%", color.green)
    f_label(p75, "75%", color.green)
    f_label(p50, "MD",  color.white)
    f_label(p25, "25%", color.red)
    f_label(p05, "05%", color.red)


    if showtbl 
        var table statsTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)
    

        table.cell(statsTable, 0, 0, "NB ANALYSIS", text_color=color.white, text_size=size.large)
        table.cell(statsTable, 1, 0, "STATUS",      text_color=color.white, text_size=size.large)
    

        table.cell(statsTable, 0, 1, "Win Prob",    text_color=color.silver, text_halign=text.align_left)
        prob_color = main_prob > 0.5 ? color.new(color.green, 20) : color.new(color.red, 20)
        table.cell(statsTable, 1, 1, str.format("{0,number,#.#}%", main_prob * 100), bgcolor=prob_color, text_color=color.white)
    

        mc_target = p50.get(forx-1).price
        table.cell(statsTable, 0, 2, "MC Median",   text_color=color.silver, text_halign=text.align_left)
        table.cell(statsTable, 1, 2, str.tostring(mc_target, format.mintick), text_color=color.white)
    

        table.cell(statsTable, 0, 3, "Rel Volume",  text_color=color.silver, text_halign=text.align_left)
        table.cell(statsTable, 1, 3, str.tostring(rel_vol, "#.##"), text_color=color.white)


        table.cell(statsTable, 0, 4, "SIGNAL",      text_color=color.white,  text_halign=text.align_left)
        sig_color = main_sig == 1 ? color.green : color.red
        table.cell(statsTable, 1, 4, main_sig == 1 ? "LONG" : "SHORT", bgcolor=sig_color, text_color=color.black)


        table.cell(statsTable, 0, 5, "Confidence",  text_color=color.gray,   text_size=size.small)
        table.cell(statsTable, 1, 5, main_prob > 0.7 or main_prob < 0.3 ? "HIGH" : "MODERATE", text_color=color.gray, text_size=size.small)
````
