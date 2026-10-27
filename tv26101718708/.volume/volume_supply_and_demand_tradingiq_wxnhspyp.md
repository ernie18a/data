# Volume Supply and Demand [TradingIQ]

- url: https://www.tradingview.com/script/wXnHSPYP-Volume-Supply-and-Demand-TradingIQ/
- type: indicator
- pine_id: PUB;a608d47df731483c84f092c3acbced39
- version: 1.0

## Description

[b]The Next Generation of Supply and Demand[/b]

You haven't seen a single good Supply and Demand indicator until today.

Let's be honest: almost every S/D indicator you've tried is either too late, constantly repaints, or simply flags every single random pivot on the chart as a "zone." That is not how institutional trading works. Traditional support and resistance might teach you to draw lines at every turning point, but if you've been trading for more than two weeks, you know that not every pivot holds weight in the future.

This tool was built to fix that. It is designed to filter out the low-quality noise, bypass the common structural flaws of basic chart metrics, and isolate nothing but [b]genuine liquidity shock events[/b] where massive market orders actually took place.

Welcome to the [b]Volume Supply and Demand[/b] engine.

---

[b]How the Algorithm Works (The "Why")[/b]

Easier said than done, right? Finding a level that actually has institutional defense behind it requires deep mathematical screening. Instead of just looking for simple highs and lows, this algorithm detects [b]explosive price moves[/b] via an advanced multi-step screening system.

First, the script calculates the True Range of consecutive candles to establish a baseline of normal market volatility. Once that baseline is set, it actively scans for sudden, abnormal expansions in price. It analyzes the specific angle, slope, and velocity of the expansion to ensure the move is statistically anomalous.
[list]
[*] [b]Demand Zones:[/b] These are flagged when extreme buying pressure forces a rapid, high-velocity move upwards, leaving behind a massive footprint of unfilled passive limit orders.

[*] [b]Supply Zones:[/b] These are flagged when intense selling aggression ramps up instantly, completely rejecting higher prices and driving the market down with severe negative velocity.
[/list]
We strictly filter out the low-quality, minor pivot points. Once the strict qualifications of velocity and range expansion are met, the zone is detected and locked in instantly.
---
[b]Structure vs. Normal Support & Resistance[/b]

To trade effectively, you must understand why these zones behave differently than standard horizontal support and resistance lines.

Traditional support and resistance lines can theoretically be drawn anywhere the market decides to turn around, regardless of the volume or speed behind the move. This creates messy charts cluttered with hundreds of psychological lines that offer no real edge.

This engine is different because it maps out an entire premium or discount [b]zone[/b] based on the exact candle structural properties where the initial institutional imbalance occurred. It targets the literal [i]origin of the reaction[/i], creating a highly precise boundary where a major market participant stepped in aggressively to flip the auction control.

---

[b]Deep-Dive Order Flow Features[/b]

We didn't just build a box-drawing tool. We added an entirely new dimension of volume analysis to help you gauge the actual internal strength of these levels.

[list]
[*] [b]Origin Volume Profiles:[/b] This is the game-changer. For every valid Supply or Demand zone generated, the indicator dynamically projects a micro Volume Profile [i]directly inside the specific structural move that created the zone[/i]. You get an immediate, visually clear picture of exactly where the heavy volume was transacted during that specific liquidity event.

[*] [b]Delta & POC Lines:[/b] The algorithm identifies the Point of Control (POC) for both the buy-volume side and the sell-volume side independently. By plotting these lines, you can see precisely where the buyers or sellers exhibited their maximum aggression right before the major expansion occurred.

[*] [b]Time-Based Profiles:[/b] Volume isn't the only metric that matters. You can change the profile type inside the settings to "Time" to generate a profile that maps out exactly where the price spent the most time consolidating before exploding out of the zone.

[*] [b]Auto Hit-Deletion:[/b] The more a level is traded into, the weaker it gets as the resting passive orders are continuously matched and filled. To prevent you from trading dead levels, the indicator includes an automated hit-deletion toggle. The moment the price decisively pierces through a zone, the script recognizes the liquidity exhaustion and wipes the zone from your chart.
[/list]

---

[b]Settings & Optimization Guidelines[/b]

Because this script relies on heavy historical array calculations and complex request structures, proper optimization is essential for a smooth charting experience:

[list]
[*] [b]S/D Zone Style (Wick, Body, Candle):[/b] This dictates the strictness of your zone boundaries.
[list]

[*] [i]Wick (Default & Strongly Recommended):[/i] Draws the zone across the precise wick of the origin candle, capturing the maximum premium/discount extremity.

[*] [i]Body / Candle:[/i] Alternative constraints that alter the vertical width of the boxes based on the candle open and close values.
[/list]

[*] [b]Max Zone Age (Bars):[/b] A zone created hundreds of bars ago losing its relevance because the participants holding those orders have likely closed their positions. This setting expires old zones to keep your chart fresh. If your chart experiences loading delays, lower this setting to roughly 200 bars.

[*] [b]Calculated Bars:[/b] To manage the calculation weight of the Epanechnikov kernel filtering and volume slice matrices, you can adjust the total calculation window. If your chart shows a red runtime error, lower this setting from 5000 down to 2000 bars.

[*] [b]Show Volume at Level:[/b] Turning this on overlays the raw numerical transaction data over each individual profile block, allowing for precise order flow calculation.
[/list]
---
[b]The Core Trading Logic[/b]

When a zone is formed by a massive imbalance of aggressive market orders, institutional participants frequently leave resting passive limit orders behind because the market moved too quickly to fill their entire block. When price returns to this exact zone for the first time, those resting orders are triggered. This acts as a defense line, forcing an aggressive, fast reversal.

If price returns to a zone multiple times, or if it begins to grind and spend a long time consolidating inside a box, that is a major warning sign. It means liquidity is actively depleting, the passive orders are being entirely consumed, and a massive liquidity shock breakout is right around the corner.

[quote]Disclaimer: This is not financial advice. Always test the mechanics against your own personal edge, backtest thoroughly, and integrate it properly within your broader risk management plan.[/quote]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ

//@version=6
indicator("Volume Supply and Demand [TradingIQ]"
 , overlay = true
 , max_bars_back = 5000
 , max_boxes_count = 500
 , max_labels_count = 500
 , max_lines_count = 500
 , max_polylines_count = 100
 , calc_bars_count = 20000
 )

// HEAD {

// types {

enum ProfileType
    Volume = "Volume"
    Time = "Time"
    Raw = "Raw"

enum Direction
    up = "Up"
    down = "Down"
    neutral = "Neutral"

type Candle
    float h
    float l
    float w
    float direction

type Data
    Candle[] candle

type CandleData
    Data[] data
    bool ready = false


type ProfileData
    float[] sum_bins
    float[] bullish_bins
    float[] bearish_bins
    float bullish_mode = na
    float bearish_mode = na
    float ratio = na
    float vwap = na
    float bullish_vwap = na
    float bearish_vwap = na
    float min = na
    float bin_range = na
    bool ready = false

type SupplyDemand
    float top
    float bottom
    int time_left
    bool flag
    int width = 0
    
type Drawing
    box[] profile
    line[] lines
    int start_idx
    bool direction
    box sd



// types }


// helper {

timeframe_string(simple int rate = 1)=>
    var const int minimum_timeframe = 60

    var int timeframe_in_seconds = timeframe.in_seconds(timeframe.period)
    var int new_timeframe_seconds = math.max(minimum_timeframe, timeframe_in_seconds / rate)
    var string ltf_string = timeframe.from_seconds(new_timeframe_seconds)

    ltf_string

// }


// tick generation {

method profile_type_select(simple ProfileType self)=>
    switch self
        ProfileType.Volume => volume
        ProfileType.Time => timeframe.in_seconds(timeframe.period)
        ProfileType.Raw => 1


polarity()=>
    switch
        open > close => -1
        open == close => 0
        open < close => 1
        => 0


fix(float[] self, float source, simple int rate)=>
    switch
        na(self) or self.size() == 0 => array.new<float>(rate, source)
        self.size() < rate => self.copy().concat(array.new<float>(rate - self.size(), nz(self.last(), source)))
        => self

fix(int[] self, int source, simple int rate)=>
    switch
        na(self) or self.size() == 0 => array.new<int>(rate, source)
        self.size() < rate => self.copy().concat(array.new<int>(rate - self.size(), nz(self.last(), source)))
        => self

fix(Data[] self, int source, simple int rate)=>
    switch
        na(self) or self.size() == 0 => array.new<Data>(rate, Data.new(array.new<Candle>(rate, Candle.new(high, low, 0, 0))))
        self.size() < rate => self.copy().concat(array.new<Data>(rate - self.size(), self.last()))
        => self

ltf_tick(simple int rate = 1, simple int max_window_size = 100, simple ProfileType profile_type = ProfileType.Volume)=>
    var string timeframe = timeframe_string(rate)
    var int ltf_size = timeframe.in_seconds(timeframe.period) / timeframe.in_seconds(timeframe)

    // Candle[] candle
    [h, l, profType, pol] = request.security_lower_tf(
           syminfo.tickerid
         , timeframe 
         , [high, low, profile_type_select(profile_type), polarity()])


    Candle[] candle = array.new<Candle>()

    size = h.size()
    if size > 0 

        for i = 0 to h.size() - 1
            candle.push(Candle.new(h.get(i), l.get(i), profType.get(i), pol.get(i)))


    var CandleData data = CandleData.new(array.new<Data>(), false)
    
    var bool ready = false
    
    if ready
        data.data.unshift(Data.new(candle))
        data.ready := data.data.first().candle.size() > 0

        while data.data.size() > max_window_size
            data.data.pop()

    else
        ready := candle.size() > 0
    data

// data generation }

// helpers {

loop_range(self, int period = na)=>
    math.min(self.size(), nz(period, self.size())) - 1

method max(Data[] self, int period = na)=>
    float max = 0
    for i = 0 to loop_range(self, period)
        Candle[] price = self.get(i).candle
        for j = 0 to loop_range(price, period)
            max := math.max(max, price.get(j).h)
    max

method min(Data[] self, int period = na)=>
    float min = 3.402823466e+38
    for i = 0 to loop_range(self, period)
        Candle[] price = self.get(i).candle
        for j = 0 to loop_range(price, period)
            min := math.min(min, price.get(j).l)
    min

method add(float[] self, float value, int idx)=>
    self.set(idx, self.get(idx) + value)

method div(float[] self, float value, int idx)=>
    self.set(idx, math.max(0, math.min(1, value == 0 ? 0 : self.get(idx) / value)))

// helpers }

// make profile {

method find_size(Data[] self, int period, int number_of_bins)=>
    float scale = syminfo.mintick
    float min_value = self.min(period)
    float max_value = self.max(period)
    float full_range = (max_value - min_value)
    int target_bins = math.min(math.max(1, int(full_range / scale)), number_of_bins)
    float target_range = full_range / target_bins
    [target_bins, target_range, min_value]

method config(ProfileData self, Data[] data_array, int number_of_bins, int period)=>
    [target_bins, target_range, min_value] = data_array.find_size(period, number_of_bins)
    self.sum_bins := array.new<float>(target_bins, 0)
    self.bearish_bins := array.new<float>(target_bins, 0)
    self.min := min_value
    self.bin_range := target_range
    self.ready := true

method size_bins(ProfileData self, int target_bins)=>
    self.sum_bins := array.new<float>(target_bins, 0)
    self.bullish_bins := array.new<float>(target_bins, 0)
    self.bearish_bins := array.new<float>(target_bins, 0)
    
    if false
        log.info("void")

bin_number(float price, float min, float rng, float bins)=>
    math.min(math.max(1, math.ceil((price - min) / rng)) - 1, bins - 1)

method market_profile_data(CandleData self, int number_of_bins = 100, int period = na)=>
    ProfileData profile_data = ProfileData.new(array.new<float>(number_of_bins, 0), array.new<float>(number_of_bins, 0), array.new<float>(number_of_bins, 0))
    if self.ready
        Data[] data_array = self.data

        [target_bins, target_range, min_value] = data_array.find_size(period, number_of_bins)
        profile_data.size_bins(target_bins)

        profile_data.min := min_value
        profile_data.bin_range := target_range
        profile_data.ready := true

        float bullish_sum = 0
        float bearish_sum = 0
        float full_sum = 0

        float vwap = 0
        float bullish_vwap = 0
        float bearish_vwap = 0

        for i = 0 to loop_range(data_array, period)
            Data data = data_array.get(i)
            for j = 0 to data.candle.size() - 1
                Candle candle = data.candle.get(j)

                float High = candle.h
                float Low = candle.l
                float avg_price = math.avg(High, Low)
                int polarity = int(candle.direction)

                float top_bin = bin_number(High, min_value, target_range, target_bins)
                float bottom_bin = bin_number(Low, min_value, target_range, target_bins)
                float number_of_hits = top_bin - bottom_bin + 1

                for k = 0 to number_of_hits - 1
                    int bin_number = int(bottom_bin) + k
                    float value = candle.w / number_of_hits

                    profile_data.sum_bins.add(value, bin_number)

                    float weighted_price = avg_price * value

                    vwap += weighted_price
                    full_sum += value

                    if polarity >= 0
                        bullish_vwap += weighted_price
                        bullish_sum += value
                        profile_data.bullish_bins.add(value, bin_number)

                    if polarity <= 0
                        bearish_vwap += weighted_price
                        bearish_sum += value
                        profile_data.bearish_bins.add(value, bin_number)



        if bullish_sum != 0 
            profile_data.bullish_vwap := nz(bullish_vwap / bullish_sum)
        else
            profile_data.bullish_vwap := na

        if bearish_sum != 0 
            profile_data.bearish_vwap := nz(bearish_vwap / bearish_sum)
        else
            profile_data.bearish_vwap := na

        if full_sum != 0
            profile_data.vwap := vwap / full_sum
        else
            profile_data.vwap := na

        profile_data.ratio := bullish_sum / full_sum

    profile_data

// make profile }


// filter {

epanechnikov_kernel(float source, float bandwidth)=>
    math.abs(source/bandwidth) <= 1 ? 0.75 * (1 - math.pow(source/bandwidth, 2)) : 0.0

filter_matrix(int current_bins, float period)=>
    matrix<float> filter_matrix = matrix.new<float>(current_bins, current_bins, 0)
    float[] norm = array.new<float>()
    float target = current_bins - 1
    for row = 0 to target
        float sum = 0
        for column = 0 to target
            float position = column - row
            float kernel = epanechnikov_kernel(position, period)
            filter_matrix.set(row, column, kernel)
            sum += kernel
        norm.push(sum)

    for row = 0 to target
        float sum = 1 / norm.get(row)
        for column = 0 to target
            filter_matrix.set(row, column, filter_matrix.get(row, column) * sum)
    filter_matrix

method filter_profile(ProfileData self, float period = 8)=>
    ProfileData data = ProfileData.new(self.sum_bins, self.bullish_bins, self.bearish_bins, self.bullish_mode, self.bearish_mode, self.ratio, self.vwap, self.bullish_vwap, self.bearish_vwap, self.min, self.bin_range, self.ready)

    var matrix<float> filter = matrix.new<float>()
    int bins = 0
    if period > 1
        bins := self.sum_bins.size()

        if bins != nz(bins[1], bins) or period != nz(period[1], period) or filter.columns() == 0
            filter := filter_matrix(bins, period)

        data.sum_bins := filter.copy().mult(self.sum_bins)
        data.bullish_bins := filter.copy().mult(self.bullish_bins)
        data.bearish_bins := filter.copy().mult(self.bearish_bins)
        
    data

// filter }

// normalize {

method normalize(ProfileData self)=>
    if self.ready
        float max = self.sum_bins.max()
        for i = 0 to self.sum_bins.size() - 1
            self.sum_bins.div(max, i)
            self.bullish_bins.div(max, i)
            self.bearish_bins.div(max, i)
    self

// normalize }

// poc {

method mode_value(float[] self)=>
    float mode_value = na
    mode_value := self.max()
    mode_value

method mode_index(float[] self)=>
    int mode_index = na
    mode_index := self.indexof(self.max())
    mode_index

method mode_price(float[] self, float min, float bin_range)=>
    float mode_price = na
    mode_price := min + (self.mode_index() + 0.5) * bin_range
    mode_price

// poc }

// value area {

method profile_sum(ProfileData self)=>
    float profile_sum = 0
    if self.ready
        for bin in self.sum_bins
            profile_sum += bin
    profile_sum

method find_value_area(ProfileData self, float percent = 70)=>
    int top_idx = na
    int bottom_idx = na
    if self.ready
        float profile_sum = self.profile_sum()
        float area_sum = self.sum_bins.mode_value()
        int poc_idx = self.sum_bins.mode_index()
        
        int max_idx = self.sum_bins.size() - 1

        top_idx := poc_idx
        bottom_idx := poc_idx
        for i = 0 to max_idx
            if top_idx < max_idx
                top_idx += 1
                area_sum += self.sum_bins.get(top_idx)
            
            if bottom_idx > 0
                bottom_idx -= 1
                area_sum += self.sum_bins.get(bottom_idx)
            
            float area_percent = area_sum / profile_sum * 100
            if area_percent >= percent
                break

        top_idx += 1
    [top_idx, bottom_idx]

// value area }

// draw {


method draw_market_profile(Drawing drawing, ProfileData self , int scale = 1, int offset, simple color bullish_color = color.green, simple color bearish_color = color.red, simple bool show_vol = false)=>
    if self.ready
        float min_price = self.min
        float bin_range = self.bin_range
        int left = bar_index - offset

        float min_vol = self.sum_bins.min()
        float max_vol = self.sum_bins.max()
        float range_vol = math.max(max_vol - min_vol, 1e-10)

        [va_top_idx, va_bottom_idx] = self.find_value_area(70)

        for i = 0 to self.sum_bins.size() - 1
            float bottom = min_price + bin_range * i
            float top = bottom + bin_range
            float sum_vol = self.sum_bins.get(i)

            float bull_v = self.bullish_bins.get(i)
            float bear_v = self.bearish_bins.get(i)
            bool is_bullish = bull_v >= bear_v

            int norm = int(math.round(1 + ((sum_vol - min_vol) * 10) / range_vol))
            norm := math.max(1, math.min(norm, 10))

            string blocks = str.repeat("█", norm)
            
            int padding = math.max(0, 10 - str.length(blocks))
            string spaces = padding > 0 ? str.repeat(" ", padding) : (str.length(blocks) == 10 ? " " : "")

            string get_text = ""
            int box_left = left
            int box_right = left + scale
            string h_align = text.align_left

            if is_bullish
                get_text := blocks + spaces
                if show_vol
                    get_text += str.tostring(sum_vol, format.volume)
            else
                box_left := left - scale
                box_right := left
                h_align := text.align_right
                get_text := spaces + blocks
                if show_vol
                    get_text := str.tostring(sum_vol, format.volume) + " " + get_text

            color base_col = is_bullish ? bullish_color : bearish_color
            color col = color.from_gradient(norm, 0, 10, color.new(base_col, 90), color.new(base_col, 45))

            if i < va_bottom_idx or i > va_top_idx
                col := color.new(color.gray, 60)

            drawing.profile.push(box.new(
              left          = box_left, 
              top           = top, 
              right         = box_right, 
              bottom        = bottom, 
              text          = get_text, 
              text_halign   = h_align, 
              text_valign   = text.align_center, 
              border_color  = color(na), 
              bgcolor       = #00000000, 
              xloc          = xloc.bar_index, 
              text_color    = col,
              force_overlay = true 
             )
             )
    drawing



method set_poc(ProfileData self)=>
    if self.ready
        self.bullish_mode := self.bullish_bins.mode_price(self.min, self.bin_range)
        self.bearish_mode := self.bearish_bins.mode_price(self.min, self.bin_range)
    self

method draw_poc(Drawing drawing, ProfileData self, int scale, int offset, color bullish, color bearish, int line_width = 2, bool ext = true)=>

    if self.ready
        int right = bar_index + scale
        int left = bar_index - offset
        float bull_price = self.bullish_mode
        float bear_price = self.bearish_mode

        string extend = switch
            ext => extend.right
            => extend.none

        drawing.lines.push(line.new(left, bull_price, right, bull_price, xloc.bar_index, extend, bullish, width = line_width))
        drawing.lines.push(line.new(left, bear_price, right, bear_price, xloc.bar_index, extend, bearish, width = line_width))

    drawing

// draw }


// s/d {

ema(float source = close, float length = 9)=>
    float alpha = 2 / (length + 1)
    var float smoothed = na
    smoothed := alpha * source + (1 - alpha) * nz(smoothed[1])
    smoothed

cumulative_ema(float source)=>
    var float ema_value = 0.0
    var int count = 0
    count := nz(count[1]) + 1
    ema_value := (1.0 - 2.0 / (count + 1.0)) * nz(ema_value[1]) + 2.0 / (count + 1.0) * source
    ema_value

angle(int start, int end)=>
    float atr = cumulative_ema(high - low)
    float slope = (close[start] - close[end]) / atr
    float angle_rad = math.atan(slope)
    float degrees = math.abs(math.todegrees(angle_rad))
    degrees



calculate_sd(int min_count = 4, float min_angle = 69, string style = "Body")=>
    float atr = ema(math.avg(high - low, math.abs(open - close)), int(math.min(bar_index + 1, 200))) / 4

    var int green_count = 0
    var int red_count = 0

    bool supply = false
    int supply_back = na
    var bool supply_active = false

    bool demand = false
    int demand_back = na
    var bool demand_active = false

    if open < close
        supply_active := false
        red_count := 0
        green_count += 1
    else
        demand_active := false
        green_count := 0
        red_count += 1

    float red_angle = angle(0, red_count)
    float green_angle = angle(0, green_count)

    if red_count >= min_count and red_angle >= min_angle and not supply_active and barstate.isconfirmed
        supply_active := true
        supply := true
        supply_back := red_count

    if green_count >= min_count and green_angle >= min_angle and not demand_active and barstate.isconfirmed
        demand_active := true
        demand := true
        demand_back := green_count

    float candle_top = math.max(open, close)
    float candle_bottom = math.min(open, close)

    bool demand_wick_condition = candle_bottom - low > atr
    bool supply_wick_condition = high - candle_top > atr

    float top_demand = switch style
        "Wick"   => demand_wick_condition ? candle_bottom : low + atr
        "Body"   => candle_top
        "Candle" => high
        => na

    float bottom_demand = switch style
        "Wick"   => low
        "Body"   => candle_bottom
        "Candle" => low
        => na

    float top_supply = switch style
        "Wick"   => high
        "Body"   => candle_top
        "Candle" => high
        => na

    float bottom_supply = switch style
        "Wick"   => supply_wick_condition ? candle_top : high - atr
        "Body"   => candle_bottom
        "Candle" => low
        => na

    SupplyDemand supply_data = SupplyDemand.new(top_supply[supply_back], bottom_supply[supply_back], bar_index - supply_back, supply, supply_back)
    SupplyDemand demand_data = SupplyDemand.new(top_demand[demand_back], bottom_demand[demand_back], bar_index - demand_back, demand, demand_back)

    [supply_data, demand_data]


method draw_box(Drawing drawing, SupplyDemand self, color zone_col, bool ext)=>
    if self.flag
        box b = box.new(
          left         = self.time_left, 
          top          = self.top, 
          right        = bar_index, 
          bottom       = self.bottom, 
          border_color = zone_col, 
          bgcolor      = color.new(zone_col, (color.t(zone_col) + 1) * 1.25), 
          extend       = ext ? extend.right : extend.none
          )
        drawing.sd := b
    drawing
        
// }


// main {

// main {

method delete(Drawing self)=>
    while self.profile.size() > 0
        self.profile.shift().delete()
    while self.lines.size() > 0
        self.lines.shift().delete()
    self.sd.delete()
    self


method clean(Drawing[] self, int max = 20, int max_age = 200, bool enable_break = false)=>
    while self.size() > max
        Drawing drawing = self.shift().delete()

    for [index, drawing] in self
        int age = bar_index - drawing.start_idx
        bool too_old = age >= max_age
        bool broke = switch
            drawing.direction => close > drawing.sd.get_top()
            => close < drawing.sd.get_bottom()
        broke := broke and enable_break

        if (broke or too_old) and barstate.isconfirmed
            drawing.delete()
            self.remove(index)
        
        drawing.sd.set_right(bar_index + 1)

        for lines in drawing.lines
            lines.set_x2(bar_index + 1)

    self

market_profile(
   simple ProfileType profile_type = ProfileType.Volume
 , simple int rate = 1
 , simple int number_of_bins = 10
 , simple int period = 200
 , simple int scale = 50
 , simple float filtering = 4
 , simple bool show_profile = true
 , simple bool show_poc = true
 , simple color bullish_color = color.green
 , simple color bearish_color = color.red
 , simple int line_width = 2
 , simple bool show_vol = false
 , simple bool enable_sd = true
 , simple int max_age = 200
 , simple string sd_style = "Wick"
 , simple int max_sd = 10
 , simple color sd_sup_col = #1532d8
 , simple color sd_dem_col = #e4a701
 , simple bool sd_ext = false
 , simple bool enable_break = true
 )=>

    [supply_data, demand_data] = calculate_sd(4, 69, sd_style)

    CandleData data = ltf_tick(rate, period, profile_type)
    var ProfileData profile_data = ProfileData.new()

    var Drawing[] drawings = array.new<Drawing>()
    
    drawings.clean(max_sd, max_age, enable_break)

    bool ready = supply_data.flag or demand_data.flag

    if ready

        int width = switch
            supply_data.flag => supply_data.width
            demand_data.flag => demand_data.width
            => 1
        int data_width = math.min(width * 2 - 1, data.data.size())

        if data_width > 0

            Drawing drawing = Drawing.new(array.new<box>(), array.new<line>(), bar_index, supply_data.flag)

            profile_data := CandleData.new(data.data.slice(0, data_width), true)
             .market_profile_data(number_of_bins, period)
             .filter_profile(filtering)
            //  .normalize()
             .set_poc()

            if show_poc
                drawing.draw_poc(profile_data, scale, width, bullish_color, bearish_color, line_width, sd_ext)

            if show_profile
                drawing.draw_market_profile(profile_data, int(width * scale), width, bullish_color, bearish_color, show_vol)
            
            if enable_sd
                drawing.draw_box(supply_data, sd_sup_col, sd_ext)
                drawing.draw_box(demand_data, sd_dem_col, sd_ext)
             
            drawings.push(drawing)

        profile_data

// main }

// main }









// HEAD }


// BODY {

// inputs {

// --- [ General Profile Settings ] ---

var const string profile_group = "Profile"

var const string profile_type_tip = "Data source used to build the profile distribution."
var const string scale_tip = "Horizontal width multiplier for the profile blocks."
var const string show_profile_tip = "Toggles the visibility of the profile histograms."
var const string show_vol_at_level_tip = "Displays the numerical volume inside the profile blocks."

ProfileType profile_type = input.enum(ProfileType.Volume, "Profile Type", group = profile_group, tooltip = profile_type_tip)
bool show_profile      = input.bool(true, "Show Profile Blocks", group = profile_group, tooltip = show_profile_tip)
bool show_vol_at_level = input.bool(false, "Show Volume at Level", group = profile_group, tooltip = show_vol_at_level_tip)

// --- [ Style & Colors ] ---

var const string poc_group = "POC"

var const string show_poc_tip = "Displays extending lines indicating the Point of Control for both bullish and bearish volume."
var const string bullish_color_tip = "Shared color for bullish profile blocks and the bullish POC line."
var const string bearish_color_tip = "Shared color for bearish profile blocks and the bearish POC line."

bool show_poc          = input.bool(false, "Show POC Lines", group = poc_group, tooltip = show_poc_tip)
int line_width         = input.int(2, "POC Line Width", minval = 1, group = poc_group)
color bullish_color    = input.color(#37A3D267, "Bullish Color", group = poc_group, tooltip = bullish_color_tip)
color bearish_color    = input.color(#EDB45867, "Bearish Color", group = poc_group, tooltip = bearish_color_tip)

// --- [ Supply & Demand ] ---

var const string sd_group = "Supply & Demand"

var const string enable_sd_tip = "Toggles the background supply and demand zone boxes."
var const string max_age_tip = "Maximum number of bars a supply or demand zone will remain on the chart before expiring."
var const string max_sd_tip = "Maximum number of concurrent S/D zones allowed on the chart at once."
var const string sd_style_tip = "Calculation method for drawing the top and bottom constraints of the zones."

string sd_style        = input.string("Wick", "S/D Zone Style", options = ["Wick", "Body", "Candle"], group = sd_group, tooltip = sd_style_tip)
bool enable_sd         = input.bool(true, "Enable S/D Boxes", group = sd_group, tooltip = enable_sd_tip)
int max_age            = input.int(5000, "Max Zone Age (Bars)", minval = 1, group = sd_group, tooltip = max_age_tip)
int max_sd             = input.int(10, "Max Active Zones", minval = 1, group = sd_group, tooltip = max_sd_tip)
bool enable_break      = input.bool(true, "Enable Hit Deletion", group =   sd_group)
color sd_sup_col       = input.color(#37A3D267, "Supply Color", group = sd_group)
color sd_dem_col       = input.color(#EDB45867, "Demand Color", group = sd_group)
bool sd_ext            = input.bool(false, "Extend Zones Right", group = sd_group)


// inputs }


// calculate {



// Hardcoded core constraints
int scale = 2//             = input.int(2, "Profile Scale Width", minval = 1, group = profile_group, tooltip = scale_tip)
int rate = 5
int number_of_bins = 12
int period = 50
float filtering = 2.0

ProfileData profile = market_profile(
  profile_type   = profile_type
 , rate           = rate
 , number_of_bins = number_of_bins
 , period         = period
 , scale          = scale
 , filtering      = filtering
 , show_profile   = show_profile
 , show_poc       = show_poc
 , bullish_color  = bullish_color
 , bearish_color  = bearish_color
 , line_width     = line_width
 , show_vol       = show_vol_at_level
 , enable_sd      = enable_sd
 , max_age        = max_age
 , sd_style       = sd_style
 , max_sd         = max_sd
 , sd_sup_col     = sd_sup_col
 , sd_dem_col     = sd_dem_col
 , sd_ext         = sd_ext
 , enable_break   = enable_break
 )

// calculate }
````
