<!-- tradingview-pine-id: PUB;E4vbQg2GTP2ABnzDTHTAXcS3yJOhYC3n -->
<!-- tradingviewscripts-format: 1 -->
# Spread by

Source: https://www.tradingview.com/script/tEDVnpgS-Spread-by/

## Description

//Every spread & central tendency measure in 1 script with comfortable visualization, including scrips's status line.

Spread measures:
- Standard deviation (for most cases);
- Average deviation (if there are extreme values);
- GstDev - Geometric Standard Deviation (exclusively for Geometric Mean);
- HstDev - Harmonic Deviation (exclusively for Harmonic Mean).

These modified functions will calculate everything right, they will take source, length, AND basis of your choice, unlike the ones from TW.

Central tendency measures:
- Mean (if everything's cool & equal);
- Median (values clustering towards low/high part of the rolling window);
- Trimean (3/more distinguishable clusters of data);
- Midhinhe (2 distinguishable clusters of data);
- Geometric Mean (   |low.. ... ... .. .... ...  .    .    .     .   .        .    .          .               .                        .                   .                      .high|   this kinda data); <- Exp law
- Harmonic Mean {   |low.                       .                 .             .             .         .          .       .  . .    .     .  .  .   .. . .  .high| kinda data).  <- Reciprocal law

Listen:
1) Don't hesitate using Standard Deviation with non-mean, like "Midhinge Standard Devition", despite what ol' stats gurus gonna say, it works when it's appropriate;
2) Don't check log space while using Geometric Mean & Geometric Standard Deviation, these 2 implement log stuff by design, I mean unless u wanna make it double xd
3) You can use this script, modify it how you want, ask me questions whatever, just make money using it;
4) Use Midrange & Midpoints in tandem when data follows ~addition law (like this .  .  .   .   .     .   .  .    .   .     .   .   .   .   .    .  .   .    .     .     .).  <- just addition law

Look at the data, choose spread measure first, then choose central tendency measure, not vice versa.

!!!
Ain't gonna place ® sign on standard deviations like one B guy did in 1980s lmao, but if your wanna use Harmonic Deviations in science/write about/cite it/whatever, pls give me a lil credit at least, I've never seen it anywhere and unfortunately had to develop it by myself. it's useful when your data develops by reciprocals law (opposite to exponential).

Peace TW

---

## Source Code

````pine
//@version=6
indicator('Spread by', 'Spread by', true, timeframe = '', timeframe_gaps = true)
//by gorx1 & midtownsk8rguy


//  dependencies........................................................................................................
mean_power(array<float> data, array<float> weights, exp, len) =>
    sum = 0.

    for i = 0 to len - 1
        sum += math.pow(data.get(i), exp) * weights.get(i)

    math.pow(sum / weights.sum(), 1 / exp)


mean_lehmer(array<float> data, array<float> weights, exp, len) =>
    sum   = 0.
    sum_w = 0.

    for i = 0 to len - 1
        sum   += math.pow(data.get(i), exp    ) * weights.get(i)
        sum_w += math.pow(data.get(i), exp - 1) * weights.get(i)

    sum / sum_w


dev_power(array<float> data, array<float> weights, center, exp, len) =>
    sum = 0.

    for i = 0 to len - 1
        sum += math.pow(math.abs(data.get(i) - center), exp) * weights.get(i)

    math.pow(sum / weights.sum(), 1 / exp)


multisort(array_base, array_second, reverse = false) =>
    len = array_base.size()

    sorted_indices      = array.sort_indices(array_base, reverse ? order.descending : order.ascending)
    sorted_array_base   = array.new_float(len)
    sorted_array_second = array.new_float(len)
    
    for i = 0 to len - 1
        idx = sorted_indices.get(i)
        
        sorted_array_base  .set(i, array_base  .get(idx))
        sorted_array_second.set(i, array_second.get(idx))
    

    [sorted_array_base, sorted_array_second]


wpnr(data, weights, len, p) =>
    [sorted_data, sorted_weights] = multisort(data, weights)
    
    sorted_weights_cum = array.new_float(len, sorted_weights.get(0))

    if len > 1
        for i = 1 to len - 1
            sorted_weights_cum.set(i, sorted_weights_cum.get(i - 1) + sorted_weights.get(i))
    
    wpnr  = 0.0
    thres = sorted_weights.sum() / 100 * p

    for i = 0 to len - 1
        if sorted_weights_cum.get(i) >= thres
            wpnr := sorted_data.get(i)
            break
    

    wpnr


quartiles(data, weights, len) => // returns 25th, 50th and 75th percentiles
    [sorted_data, sorted_weights] = multisort(data, weights)
    sorted_weights_sum            = sorted_weights.sum()


    threshold_p25 = sorted_weights_sum * (    1 / 4)
    threshold_p50 = sorted_weights_sum * (    1 / 2)
    threshold_p75 = sorted_weights_sum * (1 - 1 / 4)
        

    float p25  = na
    float p50  = na
    float p75  = na


    sorted_weights_cum = 0.

    for i = 0 to len - 1
        sorted_weights_cum += sorted_weights.get(i)  
        sorted_residual     = sorted_data   .get(i)

        if na(p25) and sorted_weights_cum >= threshold_p25
            p25 := sorted_residual
        if na(p50) and sorted_weights_cum >= threshold_p50
            p50 := sorted_residual
        if na(p75) and sorted_weights_cum >= threshold_p75
            p75 := sorted_residual

        if not na(p75)
            break


    [p25, p50, p75]


dev_median(data, weights, center, len) =>
    residuals = array.new_float(len, 0)

    for [i, v] in data
        residuals.set(i, math.abs(data.get(i) - center))

    wpnr(residuals, weights, len, 50)


ptd(data, lambda = 0) => lambda == 0 ? math.log(data) : math.pow(data,     lambda)
pti(data, lambda = 0) => lambda == 0 ? math.exp(data) : math.pow(data, 1 / lambda)
//  dependencies........................................................................................................


//  main................................................................................................................
type_center = input.string('Contraharmonic Mean'       , 'center type'   ,
 ['Mean', 'Median', 'Trimean', 'Midhinge', 'Midrange', 'RMS', 'Cubic Mean', 'Contraharmonic Mean'])
type_dev    = input.string('Average Absolute Deviation', 'deviation type',
 ['Standard Deviation', 'Average Absolute Deviation', 'Median Absolute Deviation', 'Range / 4'])

source = input(close,                                                                inline = '1', group = 'Data')
lambda = input(1.   , 'Power transform', '• no transform if 1\n• ln transform if 0', inline = '1', group = 'Data')

length = input(64   , 'length', 'make it 0 to calculate over all available data')
time_  = input(true , 'Sequence'             , inline = '1', group = 'Weighting by:')
force  = input(true , 'Inferred volume delta', inline = '1', group = 'Weighting by:')


src = ptd(source, lambda)
len = length < 1 ? bar_index + 1 : length


data    = array.new_float(len)
weights = array.new_float(len)

for i = 0 to len - 1
    weight = (time_ ? (len - i) : 1) * (force ? 256 * math.abs(close[i] - open[i]) / syminfo.mintick + 1 : 1)

    data   .set(i, src[i])
    weights.set(i, weight)


[p25, p50, p75] = quartiles(data, weights, len)
min             = ta.lowest (src, len)
max             = ta.highest(src, len)


center = switch type_center
    'Mean'                => mean_power (data, weights, 1, len)
    'RMS'                 => mean_power (data, weights, 2, len)
    'Cubic Mean'          => mean_power (data, weights, 3, len)
    'Contraharmonic Mean' => mean_lehmer(data, weights, 2, len)
    'Median'              => p50
    'Trimean'             => (p25 + p50 * 2 + p75) / 4
    'Midhinge'            => (p25 + p75) / 2
    'Midrange'            => (min + max) / 2

dev = switch type_dev
    'Standard Deviation'         => dev_power (data, weights, center,  2, len)
    'Average Absolute Deviation' => dev_power (data, weights, center,  1, len)
    'Median Absolute Deviation'  => dev_median(data, weights, center    , len)
    'Range / 4'                  => ta.range(src, len) / 4


low_dev3 = center - dev * 3
low_dev2 = center - dev * 2
low_dev1 = center - dev * 1
basis    = center
upp_dev1 = center + dev * 1
upp_dev2 = center + dev * 2
upp_dev3 = center + dev * 3
//  main................................................................................................................


//  visuals.............................................................................................................
viz_off = input(1, 'plotting offset', group = 'style') //always 1 for objective analysis, latest datapoint self inclusion should Not be done

plot(pti(low_dev3, lambda), 'Lower dev 3', color.red   , offset = viz_off)
plot(pti(low_dev2, lambda), 'Lower dev 2', color.red   , offset = viz_off)
plot(pti(low_dev1, lambda), 'Lower dev 1', color.purple, offset = viz_off)
plot(pti(basis   , lambda), 'basis'      , color.purple, offset = viz_off)
plot(pti(upp_dev1, lambda), 'Upper dev 1', color.purple, offset = viz_off)
plot(pti(upp_dev2, lambda), 'Upper dev 2', color.blue  , offset = viz_off)
plot(pti(upp_dev3, lambda), 'Upper dev 3', color.blue  , offset = viz_off)
//  visuals.............................................................................................................


//  ∞
````
