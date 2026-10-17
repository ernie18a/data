# Optimized Grid with KNN_2.0

- url: https://www.tradingview.com/script/zWZ7sMhP/
- type: strategy
- pine_id: PUB;29b4910079fe4162bd2535b70d35f596
- version: 1.0

## Description

Strategy Overview
This strategy, named "Optimized Grid with KNN_2.0," is designed to optimize trading decisions using a combination of grid trading, K-Nearest Neighbors (KNN) algorithm, and a greedy algorithm. The strategy aims to maximize profits by dynamically adjusting entry and exit thresholds based on market conditions and historical data.

Key Components
Grid Trading:

The strategy uses a grid-based approach to place buy and sell orders at predefined price levels. This helps in capturing profits from market fluctuations.
K-Nearest Neighbors (KNN) Algorithm:

The KNN algorithm is used to optimize entry and exit points based on historical price data. It identifies the nearest neighbors (similar price movements) and adjusts the thresholds accordingly.
Greedy Algorithm:

The greedy algorithm is employed to dynamically adjust the stop-loss and take-profit levels. It ensures that the strategy captures maximum profits by adjusting thresholds based on recent price changes.
Detailed Explanation
Grid Trading:

The strategy defines a grid of price levels where buy and sell orders are placed. The openTh and closeTh parameters determine the thresholds for opening and closing positions.
The t3_fast and t3_slow indicators are used to generate trading signals based on the crossover and crossunder of these indicators.
KNN Algorithm:

The KNN algorithm is used to find the nearest neighbors (similar price movements) in the historical data. It calculates the distance between the current price and historical prices to identify the most similar price movements.
The algorithm then adjusts the entry and exit thresholds based on the average change in price of the nearest neighbors.
Greedy Algorithm:

The greedy algorithm dynamically adjusts the stop-loss and take-profit levels based on recent price changes. It ensures that the strategy captures maximum profits by adjusting thresholds in real-time.
The algorithm uses the average_change variable to calculate the average price change of the nearest neighbors and adjusts the thresholds accordingly.

## Source Code

````pine
//@version=6
strategy('Optimized Grid with KNN_2.0', overlay=true, close_entries_rule="ANY", pyramiding=10, commission_type=strategy.commission.percent, commission_value=0.05, initial_capital=10000, default_qty_type=strategy.cash, currency="USDT", default_qty_value=2000)

startTime = input.time(timestamp("05 Dec 2022 03:00 +0000"), title="Start", group="Back Test")
endTime = input.time(timestamp("01 Jan 2099 23:59 +0000"), title="End", group="Back Test")
timeCond = (time > startTime) and (time < endTime)

openTh = input.int(3, title="Protect", group="Grid") / 100
closeTh = input.int(5, title="Profit", group="Grid") / 100

fn_t3(src, length) =>
    axe1 = ta.ema(src, length)
    axe2 = ta.ema(axe1, length)
    axe3 = ta.ema(axe2, length)
    axe4 = ta.ema(axe3, length)
    axe5 = ta.ema(axe4, length)
    axe6 = ta.ema(axe5, length)
    ab = 0.7
    ac1 = -ab * ab * ab
    ac2 = 3 * ab * ab + 3 * ab * ab * ab
    ac3 = -6 * ab * ab - 3 * ab - 3 * ab * ab * ab
    ac4 = 1 + 3 * ab + ab * ab * ab + 3 * ab * ab
    avg = ac1 * axe6 + ac2 * axe5 + ac3 * axe4 + ac4 * axe3

t3_fast = fn_t3(close, 5)
t3_slow = fn_t3(close, 8)

num = strategy.opentrades
min_price = num > 0 ? strategy.opentrades.entry_price(num - 1) : na

// KNN optimization for entry and exit points
k = input.int(5, title="K (Number of Neighbors)", minval=1)
window_size = input.int(20, title="Window Size", minval=1)

var float[] features = na
var float[] distances = na
var int[] nearest_neighbors = na

var float adjusted_openTh = na
var float adjusted_closeTh = na
var float average_change = na  // Define average_change as a global variable

if bar_index >= window_size - 1
    features := array.new_float(0)
    for i = 0 to window_size - 1
        array.push(features, close[i])

    distances := array.new_float(0)
    for i = 0 to window_size - 1
        var float distance = 0.0
        for j = 0 to window_size - 1
            distance += math.pow(close[j] - array.get(features, j), 2)
        distance := math.sqrt(distance)
        array.push(distances, distance)

    if array.size(distances) > 0 and array.size(distances) >= k
        nearest_neighbors := array.new_int(0)
        for i = 0 to k - 1
            var int min_index = -1
            var float min_distance = na
            for j = 0 to array.size(distances) - 1
                if na(min_distance) or array.get(distances, j) < min_distance
                    min_index := j
                    min_distance := array.get(distances, j)
            if min_index != -1
                array.push(nearest_neighbors, min_index)
                array.remove(distances, min_index)

        average_change := 0.0  // Initialize average_change
        if array.size(nearest_neighbors) > 0
            for i = 0 to array.size(nearest_neighbors) - 1
                var int index = array.get(nearest_neighbors, i)
                if index + 1 < bar_index
                    average_change += (close[index] - close[index + 1])
            average_change := average_change / array.size(nearest_neighbors)

        // Update entry and exit thresholds
        adjusted_openTh := openTh
        adjusted_closeTh := closeTh
        if average_change > 0
            adjusted_openTh := openTh * 1.1
            adjusted_closeTh := closeTh * 1.1
        else
            adjusted_openTh := openTh * 0.9
            adjusted_closeTh := closeTh * 0.9

// KNN optimized trading signals
long = ta.crossover(t3_fast, t3_slow) and average_change > 0
short = ta.crossunder(t3_fast, t3_slow) and average_change < 0

// Buy logic
if timeCond and long
    if num == 0 or (num > 0 and (close - min_price) / min_price < -adjusted_openTh * 0.5)
        strategy.entry("B" + str.tostring(num + 1), strategy.long)

// Sell logic
if timeCond and short and num > 0 and (close - min_price) / min_price > adjusted_closeTh
    strategy.close("B" + str.tostring(num), comment="S" + str.tostring(num))
````
