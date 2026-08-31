<!-- tradingview-pine-id: PUB;1f40ac99dc3c4242b096b95c26330003 -->
<!-- tradingviewscripts-format: 1 -->
# Position Cost Distribution

Source: https://www.tradingview.com/script/25py1UVB-Position-Cost-Distribution/

## Description

The Position Cost Distribution indicator (also known as the Market Position Overview, Chip Distribution, or CYQ Algorithm) provides an estimate of how shares are distributed across different price levels. Visually, it resembles the Volume Profile indicator, though they rely on distinct computational approaches.

🟠 Principle

The Position Cost Distribution algorithm is based on the principle that a security's total shares outstanding usually remains constant, except under conditions like stock splits, reverse splits, or new share issuance. It views all trading activity as simply exchanging share positions between holders at different price points.

By analyzing daily trade volume and the prior day's distribution, the algorithm infers the resulting share distribution after each day. By tracking these inferred transpositions over time, the indicator builds up an aggregate view of the estimated share concentration at each price level. This provides insights into potential buying and selling pressure zones that could form support or resistance areas.

Together with the Volume Profile, the Position Cost Distribution gives traders multiple lenses for examining market structure from both a volume and positional standpoint. Both can help identify meaningful technical price levels.

🟠 Algorithm

The algorithm initializes by allocating all shares to the price range encompassed by the first bar displayed on the chart. Preferably, the chart window should include the stock's IPO date, allowing the model to distribute shares specifically to the IPO price.

For subsequent trading sessions, the indicator performs the following calculations:

1. The daily turnover ratio is calculated by dividing the bar's trading volume by total outstanding shares.
2. For each price level (bucket), the number of shares is reduced by the turnover amount to represent shares transferring from existing holders.
3. The bar's total volume is then added to buckets corresponding to that period's price range.

Currently, the model assumes each share has an equal probability of being exchanged, regardless of how long ago it was acquired or at what price. Potential optimizations could incorporate factors like making shares held longer face a smaller chance of transfer compared to more recently purchased shares.

────────────────────────────────────────────

中文介绍：该指标为“筹码分布”的一个 TradingView 实现 :)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotraderdev

// @version=5
indicator('Position Cost Distribution', overlay = true, max_lines_count = 500, max_bars_back = 500)

import algotraderdev/contrast/1

//#region Inputs

int LOOKBACK = input.int(1000, 'Number of Most Recent Bars to Process', maxval = 20000, minval = 500, step = 250)
int CHART_X_OFFSET = input.int(100, 'Chart Offset', step = 10)
int LABEL_X_OFFSET = CHART_X_OFFSET + 4
int CHART_MAX_WIDTH = input.int(80, 'Max Width', maxval = 500, minval = 10, step = 10)
int NUM_BUCKETS = input.int(400, 'Number of Buckets', maxval = 500, minval = 50, step = 50)
color PROFITABLE_COLOR = input.color(#5d606b, 'Profitable Positions') 
color UNPROFITABLE_COLOR = input.color(#e91e63, 'Unprofitable Positions')
color CURRENT_PRICE_COLOR = input.color(color.yellow, 'Current Price')
color AVG_PRICE_COLOR = input.color(color.blue, 'Average Price')
color STATS_COLOR = input.color(#434651, 'Statistics')

//#endregion

//#region Candle

// @type The candle object holds the required information for each candle in the chart.
// @field index The `bar_index` of the candle.
// @field hi The `high` of the candle.
// @field lo The `low` of the candle.
// @field vol The `volume` of the candle.
// @field totalShares The number of total shares issued at the candle.
type Candle
    int index
    float hi
    float lo
    float vol
    float totalShares

//#endregion

//#region PCD

// @type The PCD (Position Cost Distribution) type is responsible for calculating and visualizing the distribution of
// shares at various price points.
// @field candles The stored candles based on which the distribution will be calculated.
// @field minPrice The minimum price for all the stored candles.
// @field maxPrice The maximum price for all the stored candles.
// @field step The price difference between adjacent price buckets.
// @field lines The lines that are used to plot the distributions in the chart.
// @field currentPriceLabel The label that highlights the current price.
// @field avgPriceLabel The label that highlights the average price for all shares.
// @field statsLabel The label that shows statistics for the PCD.
type PCD
    Candle[] candles
    float minPrice
    float maxPrice
    float step

    line[] lines
    label currentPriceLabel
    label avgPriceLabel
    label statsLabel

// @function Creates a new label for highlighting certain price points in the PCD.
// @param bg The background color for the label.
// @returns The created label.
newPriceLabel(color bg) =>
    label.new(
      0, 0, '',
      style = label.style_label_left,
      color = bg,
      textcolor = bg.contrast(0.6),
      size = size.small)

// @function Instantiates a new PCD.
// @returns The created PCD instance.
newPCD() =>
    line[] lns = array.new<line>()
    for i = 1 to NUM_BUCKETS
        lns.push(line.new(0, 0, 0, 0))
    PCD.new(
      candles = array.new<Candle>(),
      lines = lns,
      currentPriceLabel = newPriceLabel(CURRENT_PRICE_COLOR),
      avgPriceLabel = newPriceLabel(AVG_PRICE_COLOR),
      statsLabel = label.new(
          0, 0, '',
          style = label.style_label_up,
          size = size.normal,
          textalign = text.align_left,
          color = STATS_COLOR,
          textcolor = STATS_COLOR.contrast()))

// @function Stores the current candle for it to be analyzed later.
// Note that this method is expected to be called on every tick. The actual calculation of PCD is deferred to only when
// the last bar in the chart is reached, as an optimization.
method storeCandle(PCD this) =>
    float totalShares = request.financial(syminfo.tickerid, 'TOTAL_SHARES_OUTSTANDING', 'FQ', ignore_invalid_symbol = true)
    [index, hi, lo, vol] = request.security(syminfo.tickerid, 'D', [bar_index, high, low, volume], ignore_invalid_symbol = true)
    if not (na(totalShares) or na(hi) or na(lo) or na(vol))
        bool modified = if this.candles.size()
            Candle c = this.candles.last()
            if c.index == index
                c.hi := hi
                c.lo := lo
                c.vol := vol
                true
        if not modified
            Candle c = Candle.new(index, hi, lo, vol, totalShares)
            this.candles.push(c)
        this.minPrice := na(this.minPrice) ? lo : math.min(this.minPrice, lo)
        this.maxPrice := na(this.maxPrice) ? hi : math.max(this.maxPrice, hi)
        this.step := (this.maxPrice - this.minPrice) / NUM_BUCKETS

// @function Gets an existing line at the given index if it exists. If the line doesn't exist, then create a new line,
// insert it into the lines array, and return it instead.
// @param index The index for the line.
// @returns The line instance.
method getOrCreateLine(PCD this, int index) =>
    if index >= this.lines.size()
        line ln = line.new(0, 0, 0, 0)
        this.lines.push(ln)
        ln
    else
        this.lines.get(index)

// @function Gets the bucket index for the given price.
// @param price The price to get index for.
// @returns The bucket index for the price.
method getBucketIndex(PCD this, float price) =>
    math.min(math.floor((price - this.minPrice) / this.step), NUM_BUCKETS - 1)

// @function Gets the bucketed price for the given index
// @param index The bucket index.
// @returns The average price for the bucket.
method getBucketedPrice(PCD this, int index) =>
    (index + 0.5) * this.step + this.minPrice

// @function Calculates the distribution and visualizes it on the chart.
method update(PCD this) =>
    // Create distribution buckets for the price range.
    float[] dist = array.new_float(NUM_BUCKETS, 0)

    bool isFirstCandle = this.candles.size() == 1

    // For each candle, uniformly divide it into multiple price points based on the step.
    // TODO: consider using triangular distribution or normal distribution in future versions.
    for candle in this.candles
        float turnover = candle.vol / candle.totalShares

        // Calculate the start and end index of the buckets to fill the shares.
        int start = this.getBucketIndex(candle.lo)
        int end = this.getBucketIndex(candle.hi)
        int buckets = end - start + 1

        if isFirstCandle
            // Distribute all shares to the initial buckets.
            float shares = candle.totalShares / buckets
            for i = start to end
                dist.set(i, shares)
        else
            // For each existing bucket, reduce the number of shares by the turnover rate.
            for i = 0 to NUM_BUCKETS - 1
                dist.set(i, dist.get(i) * (1 - turnover))
            // Distribute the volume to the buckets in the candle range.
            float shares = candle.vol / buckets
            for i = start to end
                dist.set(i, dist.get(i) + shares)

    // Draw the distribution as lines on the chart.
    float lowestDisplayedPrice = na
    float highestDisplayedPrice = na
    float maxShares = dist.max()
    for [i, shares] in dist
        float price = (i + 0.5) * this.step + this.minPrice
        int width = math.round(shares / maxShares * CHART_MAX_WIDTH)
        if width != 0
            if na(lowestDisplayedPrice)
                lowestDisplayedPrice := price
            highestDisplayedPrice := price
        int x1 = bar_index + CHART_X_OFFSET
        int x2 = x1 - width
        color c =  price < close ? PROFITABLE_COLOR : UNPROFITABLE_COLOR
        line ln = this.getOrCreateLine(i)
        ln.set_xy1(x1, price)
        ln.set_xy2(x2, price)
        ln.set_color(c)

    // Calculate and highlight some interesting stats.
    //   * The current price.
    //   * The average price for all positions.
    //   * The profit ratio.
    //   * The 90% range.
    //   * The 70% range.

    // Calculate the cumulative distribution.
    float[] cumdist = dist.copy()
    for i = 1 to cumdist.size() - 1
        cumdist.set(i, cumdist.get(i - 1) + cumdist.get(i))

    // Highlight the current price.
    int closeIndex = this.getBucketIndex(close)
    this.lines.get(closeIndex).set_color(CURRENT_PRICE_COLOR)
    this.currentPriceLabel.set_text(str.format('{0,number,#.##} Current', close))
    this.currentPriceLabel.set_xy(bar_index + LABEL_X_OFFSET, close)

    // Calculate the profit ratio.
    float totalShares = cumdist.last()
    int profitIndex = math.min(closeIndex + 1, NUM_BUCKETS - 1)
    float profitRatio = cumdist.get(profitIndex) / totalShares
    
    // Calculate the average price for all positions.
    float avg = 0
    for [i, shares] in dist
        float price = this.getBucketedPrice(i)
        avg += price * (shares / totalShares)
    this.avgPriceLabel.set_text(str.format('{0,number,#.##} Average', avg))
    this.avgPriceLabel.set_xy(bar_index + LABEL_X_OFFSET, avg)
    int avgIndex = this.getBucketIndex(avg)
    this.lines.get(avgIndex).set_color(AVG_PRICE_COLOR)

    // Calculate the position ranges.
    float ninetyPctLow = this.getBucketedPrice(cumdist.binary_search_leftmost(totalShares * 0.05))
    float ninetyPctHigh = this.getBucketedPrice(cumdist.binary_search_leftmost(totalShares * 0.95))
    float seventyPctLow = this.getBucketedPrice(cumdist.binary_search_leftmost(totalShares * 0.15))
    float seventyPctHigh = this.getBucketedPrice(cumdist.binary_search_leftmost(totalShares * 0.85))
    float rangeOverlap = (seventyPctHigh- seventyPctLow) / (ninetyPctHigh- ninetyPctLow)

    // Render the stats label.
    this.statsLabel.set_text(str.format(
      'Profit Ratio:\t{0,number,#.##}%\n' +
      '90% Cost Range:\t{1,number,#.##}-{2,number,#.##}\n' +
      '70% Cost Range:\t{3,number,#.##}-{4,number,#.##}\n' +
      'Range Overlap:\t{5,number,#.##}%',
      profitRatio * 100,
      ninetyPctLow, ninetyPctHigh,
      seventyPctLow, seventyPctHigh,
      rangeOverlap * 100))
    float displayedRange = highestDisplayedPrice - lowestDisplayedPrice
    if highestDisplayedPrice - close > close - lowestDisplayedPrice
        this.statsLabel.set_y(lowestDisplayedPrice - displayedRange * 0.03)
        this.statsLabel.set_style(label.style_label_up)
    else
        this.statsLabel.set_y(highestDisplayedPrice + displayedRange * 0.03)
        this.statsLabel.set_style(label.style_label_down)
    this.statsLabel.set_x(bar_index + CHART_X_OFFSET)

//#endregion

//#region main

if syminfo.type == 'stock' and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds('D')
    var PCD pcd = newPCD()

    if last_bar_index - bar_index < LOOKBACK
        pcd.storeCandle()
    if barstate.islast
        pcd.update()

//#endregion
````
