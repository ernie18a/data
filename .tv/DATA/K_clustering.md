<!-- tradingview-pine-id: PUB;8e82f5aa4b0f4f9da1a6d8d09dab326f -->
<!-- tradingviewscripts-format: 1 -->
# K clustering

Source: https://www.tradingview.com/script/FwB6GWPC-Support-Resistance-AI-K-means-median-ThinkLogicAI/

## Description

█ OVERVIEW

K-means is a clustering algorithm commonly used in machine learning to group data points into distinct clusters based on their similarities. While K-means is not typically used directly for identifying support and resistance levels in financial markets, it can serve as a tool in a broader analysis approach.

Support and resistance levels are price levels in financial markets where the price tends to react or reverse. Support is a level where the price tends to stop falling and might start to rise, while resistance is a level where the price tends to stop rising and might start to fall. Traders and analysts often look for these levels as they can provide insights into potential price movements and trading opportunities.

█ BACKGROUND

The K-means algorithm has been around since the late 1950s, making it more than six decades old. The algorithm was introduced by Stuart Lloyd in his 1957 research paper "Least squares quantization in PCM" for telecommunications applications. However, it wasn't widely known or recognized until James MacQueen's 1967 paper "Some Methods for Classification and Analysis of Multivariate Observations," where he formalized the algorithm and referred to it as the "K-means" clustering method.

So, while K-means has been around for a considerable amount of time, it continues to be a widely used and influential algorithm in the fields of machine learning, data analysis, and pattern recognition due to its simplicity and effectiveness in clustering tasks.

█ COMPARE AND CONTRAST SUPPORT AND RESISTANCE METHODS

1)   K-means Approach:

[ * ]Cluster Formation: After applying the K-means algorithm to historical price change data and visualizing the resulting clusters, traders can identify distinct regions on the price chart where clusters are formed. Each cluster represents a group of similar price change patterns.

[ * ]Cluster Analysis: Analyze the clusters to identify areas where clusters tend to form. These areas might correspond to regions of price behavior that repeat over time and could be indicative of support and resistance levels.

[ * ]Potential Support and Resistance Levels: Based on the identified areas of cluster formation, traders can consider these regions as potential support and resistance levels. A cluster forming at a specific price level could suggest that this level has been historically significant, causing similar price behavior in the past.

[*]Cluster Standard Deviation: In addition to looking at the means (centroids) of the clusters, traders can also calculate the standard deviation of price changes within each cluster. Standard deviation is a measure of the dispersion or volatility of data points around the mean. A higher standard deviation indicates greater price volatility within a cluster.

[*]Low Standard Deviation: If a cluster has a low standard deviation, it suggests that prices within that cluster are relatively stable and less likely to exhibit sudden and large price movements. Traders might consider placing tighter stop-loss orders for trades within these clusters.

[*]High Standard Deviation: Conversely, if a cluster has a high standard deviation, it indicates greater price volatility within that cluster. Traders might opt for wider stop-loss orders to allow for potential price fluctuations without getting stopped out prematurely.

[*]Cluster Density: Each  data point is assigned to a cluster so a cluster that is more dense will act more like gravity and 

2)  Traditional Approach:

[*]Trendlines: Draw trendlines connecting significant highs or lows on a price chart to identify potential support and resistance levels.

[*]Chart Patterns: Identify chart patterns like double tops, double bottoms, head and shoulders, and triangles that often indicate potential reversal points.

[*]Moving Averages: Use moving averages to identify levels where the price might find support or resistance based on the average price over a specific period.

[*]Psychological Levels: Identify round numbers or levels that traders often pay attention to, which can act as support and resistance.

[*]Previous Highs and Lows: Identify significant previous price highs and lows that might act as support or resistance.

The key difference lies in the approach and the foundation of these methods. Traditional methods are based on well-established principles of technical analysis and market psychology, while the K-means approach involves clustering price behavior without necessarily incorporating market sentiment or specific price patterns.

It's important to note that while the K-means approach might provide an interesting way to analyze price data, it should be used cautiously and in conjunction with other traditional methods. Financial markets are influenced by a wide range of factors beyond just price behavior, and the effectiveness of any method for identifying support and resistance levels should be thoroughly tested and validated. Additionally, developments in trading strategies and analysis techniques could have occurred since my last update.

█ K MEANS ALGORITHM

The algorithm for K means is as follows:

[*]Initialize cluster centers
[*]assign data to clusters based on minimum distance
[*]calculate cluster center by taking the average or median of the clusters
[*]repeat steps 1-3 until cluster centers stop moving

█ LIMITATIONS OF K MEANS

There are 3 main limitations of this algorithm:

[*]Sensitive to Initializations: K-means is sensitive to the initial placement of centroids. Different initializations can lead to different cluster assignments and final results. 
[*]Assumption of Equal Sizes and Variances: K-means assumes that clusters have roughly equal sizes and spherical shapes. This may not hold true for all types of data. It can struggle with identifying clusters with uneven densities, sizes, or shapes.
[*]Impact of Outliers: K-means is sensitive to outliers, as a single outlier can significantly affect the position of cluster centroids. Outliers can lead to the creation of spurious clusters or distortion of the true cluster structure.

█ LIMITATIONS IN APPLICATION OF K MEANS IN TRADING

Trading data often exhibits characteristics that can pose challenges when applying indicators and analysis techniques. Here's how the limitations of outliers, varying scales, and unequal variance can impact the use of indicators in trading:

[*]Outliers are data points that significantly deviate from the rest of the dataset. In trading, outliers can represent extreme price movements caused by rare events, news, or market anomalies. Outliers can have a significant impact on trading indicators and analyses:

  Indicator Distortion: Outliers can skew the calculations of indicators, leading to   misleading signals. For instance, a single extreme price spike could cause indicators like moving averages or RSI (Relative Strength Index) to give false signals.

  Risk Management: Outliers can lead to overly aggressive trading decisions if not  properly accounted for. Ignoring outliers might result in unexpected losses or missed opportunities to adjust trading strategies.

[*]Different Scales: Trading data often includes multiple indicators with varying units and scales. For example, prices are typically in dollars, volume in units traded, and oscillators have their own scale. Mixing indicators with different scales can complicate analysis:

 Normalization: Indicators on different scales need to be normalized or standardized to ensure they contribute equally to the analysis. Failure to do so can lead to one indicator dominating the analysis due to its larger magnitude.

 Comparability: Without normalization, it's challenging to directly compare the significance of indicators. Some indicators might have a larger numerical range and could overshadow others.

[*]Unequal Variance:  Unequal variance in trading data refers to the fact that some indicators might exhibit higher volatility than others. This can impact the interpretation of signals and the performance of trading strategies:

 Volatility Adjustment: When combining indicators with varying volatility, it's essential to adjust for their relative volatilities. Failure to do so might lead to overemphasizing or underestimating the importance of certain indicators in the trading strategy.

 Risk Assessment: Unequal variance can impact risk assessment. Indicators with higher volatility might lead to riskier trading decisions if not properly taken into account.

█ APPLICATION OF THIS INDICATOR

This indicator can be used in 2 ways:

1) Make a directional trade:

[*]If a trader thinks price will go higher or lower and price is within a cluster zone, The trader can take a position and place a stop on the 1 sd band around the cluster.  As one can see below, the trader can go long the green arrow and place a stop on the one standard deviation mark for that cluster below it at the red arrow.  using this we can calculate a risk to reward ratio.
 
[*]Calculating risk to reward:  targeting a risk reward ratio of 2:1, the trader could clearly make that given that the next resistance area above that in the orange cluster exceeds this risk reward ratio.

[image]https://www.tradingview.com/x/vgp3vk1k/[/image]

2) Take a reversal Trade:

[*]We can use cluster centers (support and resistance levels) to go in the opposite direction that price is currently moving in hopes of price forming a pivot and reversing off this level.    
[*]Similar to the directional trade, we can use the standard deviation of the cluster to place a stop just in case we are wrong.  
[*]In this example below we can see that shorting on the red arrow and placing a stop at the one standard deviation above this cluster would give us a profitable trade with minimal risk.
[*]Using the cluster density table in the upper right informs the trader just how dense the cluster is.  Higher density clusters will give a higher likelihood of a pivot forming at  these levels and price being rejected and switching direction  with a larger move.

[image]https://www.tradingview.com/x/GOOAbGTK/[/image]

█ FEATURES & SETTINGS

General Settings:

[*]Number of clusters: The user can select from 3 to five clusters.  A good rule of thumb is that if you are trading intraday, less is more  (Think 3 rather than 5).  For daily 4 to 5 clusters is good.

[*]Cluster Method: To get around the outlier limitation of k means clustering,  The median was added.   This gives the user the ability to choose either k means or k median clustering.  K means is the preferred method if the user things there are no large outliers, and if there appears to be large outliers or it is assumed there are then K medians is preferred.

[*]Bars back To train on: This will be the amount of bars to include in the clustering.  This number is important so that the user includes bars that are recent but not so far back that they are out of the scope of where price can be.  For example the last 2 years we have been in a range on the sp500 so 505 days in this setting would be more relevant than say looking back 5 years ago because price would have to move far to get there.

[*]Show SD Bands: Select this to show the 1 standard deviation bands around the support and resistance level or unselect this to just show the support and resistance level by itself.

Features:

Besides the support and resistance levels and standard deviation bands, this indicator gives a table in the upper right hand corner to show the density of each cluster (support and resistance level) and is color coded to the cluster line on the chart.  Higher density clusters mean price has been there previously more than lower density clusters and could mean a higher likelihood of a reversal when price reaches these areas.

█ WORKS CITED

[*]Victor Sim, "Using K-means Clustering to Create Support and Resistance", 2020, https://towardsdatascience.com/using-k-means-clustering-to-create-support-and-resistance-b13fdeeba12
[*]Chris Piech, "K means", https://stanford.edu/~cpiech/cs221/handouts/kmeans.html

█ ACKNOLWEDGMENTS

@jdehorty- Thanks for the publish template.  It made organizing my thoughts and work alot easier.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThinkLogicAI


//@version=5
indicator("K clustering", overlay = true, max_lines_count = 10, max_labels_count = 251)

//inputs 
k = input.int(3, "Number of clusters", minval = 3, maxval = 5, step = 1)
cent_meth = input.string("K means", title="Cluster Method", options=["K means", "K median"]) 
train_n = input.int(252,"Bars back from last bar to train on", minval = 20, maxval = 1000, step = 1)
plot_band = input.bool(true, "Show SD bands")

//variables needed
x = close
max_bars_back(x, 5000)
var clust = array.new<float>(k, 0)
var sd_clust = array.new<float>(k, 0)
var n_clust = array.new<float>(k,0)
var conv = array.new<int>(0)
var bar_lab = array.new<label>(0)
var table tab = table.new(position.top_right,2, k+1)
var line ts = na
var line k1 = na
var line k2 = na
var line k3 = na
var line k4 = na
var line k5 = na
var line k6 = na
var line sh_1 = na
var line sl_1 = na
var line sh_2 = na
var line sl_2 = na
var line sh_3 = na
var line sl_3 = na
var line sh_4 = na
var line sl_4 = na
var line sh_5 = na
var line sl_5 = na
var line sh_6 = na
var line sl_6 = na



//fuctions used
euc_dist(p,q) => 
    //distance metric
    //p is the close vector and q is the cluster cecnter
    math.sqrt(math.pow(p-q,2))

subtract_array(a,b)=>
    //subtract arrays
    out = array.new<float>(array.size(a),na)
    for i = 0 to array.size(a) -1
        array.set(out,i, array.get(a,i) - array.get(b,i))
    array.sum(out)

center_method(arry)=>
    //calculate either the mean or median based on user input
    float out = 0.00
    if cent_meth == "K means"//k means clustering
        out := array.avg(arry)
    else
        out := array.median((arry))//k meedian clustering
    out

sd_method(arry, mu, ddof)=>
    //my will either be the mean or the median based on user input
    float sum_dif = 0.00
    if cent_meth == "k means"
        sum_dif := array.stdev(arry)
    else
        if arry.size() > 0
            for i = 0 to arry.size() - 1
                sum_dif += math.pow(array.get(arry, i) - mu,2)
            sum_dif := math.sqrt(sum_dif/(array.size(arry)-ddof))
    sum_dif

    

vector_params(k, a1, a2, a3, a4, a5, a6)=>
    //calculate mean, sd, and array size
    mu = array.new<float>(0)
    sd = array.new<float>(0)
    N = array.new<float>(0)
    mean_ar1 = center_method(a1)
    mean_ar2 = center_method(a2)
    mean_ar3 = center_method(a3)
    mean_ar4 = center_method(a4)
    mean_ar5 = center_method(a5)
    mean_ar6 = center_method(a6)
    sd_ar1 = sd_method(a1, mean_ar1, 0)
    sd_ar2 = sd_method(a2, mean_ar2, 0)
    sd_ar3 = sd_method(a3, mean_ar3, 0)
    sd_ar4 = sd_method(a4, mean_ar4, 0)
    sd_ar5 = sd_method(a5, mean_ar5, 0)
    sd_ar6 = sd_method(a6, mean_ar6, 0)
    n1 = array.size(a1)
    n2 = array.size(a2)
    n3 = array.size(a3)
    n4 = array.size(a4)
    n5 = array.size(a5)
    n6 = array.size(a6)
    array.push(mu, mean_ar1)
    array.push(mu, mean_ar2)
    array.push(mu, mean_ar3)
    array.push(mu, mean_ar4)
    array.push(mu, mean_ar5)
    array.push(mu, mean_ar6)
    array.push(sd, sd_ar1)
    array.push(sd, sd_ar2)
    array.push(sd, sd_ar3)
    array.push(sd, sd_ar4)
    array.push(sd, sd_ar5)
    array.push(sd, sd_ar6)
    array.push(N, n1)
    array.push(N, n2)
    array.push(N, n3)
    array.push(N, n4)
    array.push(N, n5)
    array.push(N, n6)
    [array.slice(mu,0,k), array.slice(sd, 0, k), array.slice(N, 0, k)]


// k means/median clustering
if barstate.islast
    err = 100.00
    for i = 0 to array.size(clust) - 1
        array.set(clust, i, i == 0 ? x[math.floor(train_n*.02)] : x[math.floor(train_n*((i/k)))])
    
    //run while clusters keep changing 
    while err > .01
        c1 = array.new<float>(0)
        c2 = array.new<float>(0)
        c3 = array.new<float>(0)
        c4 = array.new<float>(0)
        c5 = array.new<float>(0)
        c6 = array.new<float>(0)
        hold = array.new<int>(0)
        for i = 1 to train_n
            int idx = na
            dist = 1000000.00
            for j = 0 to k-1
                d_temp = euc_dist(x[i], array.get(clust,j))
                if d_temp < dist
                    dist := d_temp
                    idx := j
            if idx == 0
                array.push(c1, x[i])
                array.push(hold, 0)
            else if idx == 1
                array.push(c2, x[i])
                array.push(hold, 1)
            else if idx == 2
                array.push(c3, x[i])
                array.push(hold, 2)
            else if idx == 3
                array.push(c4, x[i])
                array.push(hold, 3)
            else if idx == 4
                array.push(c5, x[i])
                array.push(hold, 4)
            else if idx == 5
                array.push(c6, x[i])
                array.push(hold, 5)
        //after looping though data
        [mu, sd, n] = vector_params(k, c1, c2, c3, c4, c5, c6)
        err := math.pow(subtract_array(clust, mu),2)
        clust := array.copy(mu)
        sd_clust := array.copy(sd)
        array.push(conv,1)
        conv := array.copy(hold)
        n_clust := array.copy(n)
        
    //populate table
    table.cell(tab, 0, 0, "Cluster",  bgcolor = color.new(color.gray, 50), text_color = color.white)
    table.cell(tab, 1, 0, "Density", bgcolor = color.new(color.gray, 50), text_color = color.white)

    //visuals, table update, and stats all based on user defined number of clusters
    if k == 3
        n1 = n_clust.get(0)
        n2 = n_clust.get(1)      
        n3 = n_clust.get(2)
        denom = n1 + n2 + n3
        table.cell(tab, 1, 1, str.tostring(100*math.round(n1 / denom,3)) + "%", bgcolor = color.new(color.green,50), text_color = color.white)
        table.cell(tab, 1, 2, str.tostring(100*math.round(n2 / denom,3)) + "%", bgcolor = color.new(color.red, 50), text_color = color.white)
        table.cell(tab, 1, 3, str.tostring(100*math.round(n3 / denom,3)) + "%", bgcolor = color.new(color.blue,50), text_color = color.white)
        table.cell(tab, 0, 1, "1", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 2, "2", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 3, "3", bgcolor = color.gray, text_color = color.white)
        if n1 > 0
            k1 := line.new(bar_index - 1, array.get(clust,0), bar_index, array.get(clust,0),xloc = xloc.bar_time,extend = extend.both, color = color.green, width = 2)
            if plot_band
                sh_1 := line.new(bar_index - 1 , array.get(clust,0) + array.get(sd_clust, 0), bar_index, array.get(clust,0) + array.get(sd_clust, 0),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)
                sl_1 := line.new(bar_index - 1, array.get(clust,0) - array.get(sd_clust, 0), bar_index, array.get(clust,0) - array.get(sd_clust, 0),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)    
                linefill.new(sh_1, sl_1, color.new(color.green, 90))
        if n2 > 0
            k2 := line.new(bar_index - 1, array.get(clust,1), bar_index, array.get(clust,1),xloc = xloc.bar_time,extend = extend.both, color = color.red, width = 2)
            if plot_band
                sh_2 := line.new(bar_index - 1, array.get(clust,1) + array.get(sd_clust, 1), bar_index, array.get(clust,1) + array.get(sd_clust, 1),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)
                sl_2 := line.new(bar_index - 1, array.get(clust,1) - array.get(sd_clust, 1), bar_index, array.get(clust,1) - array.get(sd_clust, 1),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_2, sl_2, color.new(color.red, 90))
        if n3 > 0    
            k3 := line.new(bar_index - 1, array.get(clust,2), bar_index, array.get(clust,2),xloc = xloc.bar_time,extend = extend.both, color = color.blue, width = 2)
            if plot_band
                sh_3 := line.new(bar_index - 1, array.get(clust,2) + array.get(sd_clust, 2), bar_index, array.get(clust,2) + array.get(sd_clust, 2),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)
                sl_3 := line.new(bar_index - 1, array.get(clust,2) - array.get(sd_clust, 2), bar_index, array.get(clust,2) - array.get(sd_clust, 2),xloc = xloc.bar_time,extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_3, sl_3, color.new(color.blue, 90))
    else if k == 4
        n1 = n_clust.get(0)
        n2 = n_clust.get(1)      
        n3 = n_clust.get(2)
        n4 = n_clust.get(3)
        denom = n1 + n2 + n3 + n4
        table.cell(tab, 1, 1, str.tostring(100*math.round(n1 / denom,3)) + "%", bgcolor = color.new(color.green,50), text_color = color.white)
        table.cell(tab, 1, 2, str.tostring(100*math.round(n2 / denom,3)) + "%", bgcolor = color.new(color.red,50), text_color = color.white)
        table.cell(tab, 1, 3, str.tostring(100*math.round(n3 / denom,3)) + "%", bgcolor = color.new(color.blue,50), text_color = color.white)
        table.cell(tab, 1, 4, str.tostring(100*math.round(n4 / denom,3)) + "%", bgcolor = color.new(color.orange,50), text_color = color.white)
        table.cell(tab, 0, 1, "1", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 2, "2", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 3, "3", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 4, "4", bgcolor = color.gray, text_color = color.white)
        if n1 > 0
            k1 := line.new(bar_index - 1, array.get(clust,0), bar_index, array.get(clust,0),extend = extend.both, color = color.green, width = 2)
            if plot_band
                sh_1 := line.new(bar_index - 1, array.get(clust,0) + array.get(sd_clust, 0), bar_index, array.get(clust,0) + array.get(sd_clust, 0),extend = extend.both, color = color.white, width = 1)
                sl_1 := line.new(bar_index - 1, array.get(clust,0) - array.get(sd_clust, 0), bar_index, array.get(clust,0) - array.get(sd_clust, 0),extend = extend.both, color = color.white, width = 1)    
                linefill.new(sh_1, sl_1, color.new(color.green, 90))
        if n2 > 0
            k2 := line.new(bar_index - 1, array.get(clust,1), bar_index, array.get(clust,1),extend = extend.both, color = color.red, width = 2)
            if plot_band
                sh_2 := line.new(bar_index - 1, array.get(clust,1) + array.get(sd_clust, 1), bar_index, array.get(clust,1) + array.get(sd_clust, 1),extend = extend.both, color = color.white, width = 1)
                sl_2 := line.new(bar_index - 1, array.get(clust,1) - array.get(sd_clust, 1), bar_index, array.get(clust,1) - array.get(sd_clust, 1),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_2, sl_2, color.new(color.red, 90))
        if n3 > 0    
            k3 := line.new(bar_index - 1, array.get(clust,2), bar_index, array.get(clust,2),extend = extend.both, color = color.blue, width = 2)
            if plot_band
                sh_3 := line.new(bar_index - 1, array.get(clust,2) + array.get(sd_clust, 2), bar_index, array.get(clust,2) + array.get(sd_clust, 2),extend = extend.both, color = color.white, width = 1)
                sl_3 := line.new(bar_index - 1, array.get(clust,2) - array.get(sd_clust, 2), bar_index, array.get(clust,2) - array.get(sd_clust, 2),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_3, sl_3, color.new(color.blue, 90))
        if n4 > 0
            k4 := line.new(bar_index - 1, array.get(clust,3), bar_index, array.get(clust,3),extend = extend.both, color = color.orange, width = 2)
            if plot_band
                sh_4 := line.new(bar_index - 1, array.get(clust,3) + array.get(sd_clust, 3), bar_index, array.get(clust,3) + array.get(sd_clust, 3),extend = extend.both, color = color.white, width = 1)
                sl_4 := line.new(bar_index - 1, array.get(clust,3) - array.get(sd_clust, 3), bar_index, array.get(clust,3) - array.get(sd_clust, 3),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_4, sl_4, color.new(color.orange, 90))

    else if k == 5
        n1 = n_clust.get(0)
        n2 = n_clust.get(1)      
        n3 = n_clust.get(2)
        n4 = n_clust.get(3)
        n5 = n_clust.get(4)
        denom = n1 + n2 + n3 + n4 + n5
        table.cell(tab, 1, 1, str.tostring(100*math.round(n1 / denom,3)) + "%", bgcolor = color.new(color.green,50), text_color = color.white)
        table.cell(tab, 1, 2, str.tostring(100*math.round(n2 / denom,3)) + "%", bgcolor = color.new(color.red,50), text_color = color.white)
        table.cell(tab, 1, 3, str.tostring(100*math.round(n3 / denom,3)) + "%", bgcolor = color.new(color.blue,50), text_color = color.white)
        table.cell(tab, 1, 4, str.tostring(100*math.round(n4 / denom,3)) + "%", bgcolor = color.new(color.orange,50), text_color = color.white)
        table.cell(tab, 1, 5, str.tostring(100*math.round(n5 / denom,3)) + "%", bgcolor = color.new(color.yellow,50), text_color = color.white)
        table.cell(tab, 0, 1, "1", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 2, "2", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 3, "3", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 4, "4", bgcolor = color.gray, text_color = color.white)
        table.cell(tab, 0, 5, "5", bgcolor = color.gray, text_color = color.white)
        if n1 > 0
            k1 := line.new(bar_index - 1, array.get(clust,0), bar_index, array.get(clust,0),extend = extend.both, color = color.green, width = 2)
            if plot_band
                sh_1 := line.new(bar_index - 1, array.get(clust,0) + array.get(sd_clust, 0), bar_index, array.get(clust,0) + array.get(sd_clust, 0),extend = extend.both, color = color.white, width = 1)
                sl_1 := line.new(bar_index - 1, array.get(clust,0) - array.get(sd_clust, 0), bar_index, array.get(clust,0) - array.get(sd_clust, 0),extend = extend.both, color = color.white, width = 1)    
                linefill.new(sh_1, sl_1, color.new(color.green, 90))
        if n2 > 0
            k2 := line.new(bar_index - 1, array.get(clust,1), bar_index, array.get(clust,1),extend = extend.both, color = color.red, width = 2)
            if plot_band
                sh_2 := line.new(bar_index - 1, array.get(clust,1) + array.get(sd_clust, 1), bar_index, array.get(clust,1) + array.get(sd_clust, 1),extend = extend.both, color = color.white, width = 1)
                sl_2 := line.new(bar_index - 1, array.get(clust,1) - array.get(sd_clust, 1), bar_index, array.get(clust,1) - array.get(sd_clust, 1),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_2, sl_2, color.new(color.red, 90))
        if n3 > 0    
            k3 := line.new(bar_index - 1, array.get(clust,2), bar_index, array.get(clust,2),extend = extend.both, color = color.blue, width = 2)
            if plot_band
                sh_3 := line.new(bar_index - 1, array.get(clust,2) + array.get(sd_clust, 2), bar_index, array.get(clust,2) + array.get(sd_clust, 2),extend = extend.both, color = color.white, width = 1)
                sl_3 := line.new(bar_index - 1, array.get(clust,2) - array.get(sd_clust, 2), bar_index, array.get(clust,2) - array.get(sd_clust, 2),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_3, sl_3, color.new(color.blue, 90))
        if n4 > 0
            k4 := line.new(bar_index - 1, array.get(clust,3), bar_index, array.get(clust,3),extend = extend.both, color = color.orange, width = 2)
            if plot_band
                sh_4 := line.new(bar_index - 1, array.get(clust,3) + array.get(sd_clust, 3), bar_index, array.get(clust,3) + array.get(sd_clust, 3),extend = extend.both, color = color.white, width = 1)
                sl_4 := line.new(bar_index - 1, array.get(clust,3) - array.get(sd_clust, 3), bar_index, array.get(clust,3) - array.get(sd_clust, 3),extend = extend.both, color = color.white, width = 1)
                linefill.new(sh_4, sl_4, color.new(color.orange, 90))
            
        if n5 > 0
            k5 := line.new(bar_index - 1, array.get(clust,4), bar_index, array.get(clust,4),extend = extend.both, color = color.yellow, width = 2)
            if plot_band    
                sh_5 := line.new(bar_index - 1, array.get(clust,4) + array.get(sd_clust, 4), bar_index, array.get(clust,4) + array.get(sd_clust, 4),extend = extend.both, color = color.white, width = 1)
                sl_5 := line.new(bar_index - 1, array.get(clust,4) - array.get(sd_clust, 4), bar_index, array.get(clust,4) - array.get(sd_clust, 4),extend = extend.both, color = color.white, width = 1)    
                linefill.new(sh_5, sl_5, color.new(color.yellow, 90))
````
