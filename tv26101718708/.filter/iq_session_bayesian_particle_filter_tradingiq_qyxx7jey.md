# IQ Session Bayesian Particle Filter [TradingIQ]

- url: https://www.tradingview.com/script/QyXx7jEY-IQ-Session-Bayesian-Particle-Filter-TradingIQ/
- type: indicator
- pine_id: PUB;d343c5f5891a4b15852ef982f9032e27
- version: 1.0

## Description

🔹 [b]OVERVIEW[/b]

This indicator runs a genuine Sequential Monte Carlo particle filter; the Bayesian architecture used in robotics and signal tracking... on your chart! Session by session, it learns where trading volume concentrates and paints a forecast of the coming session's [b]entire volume-by-price distribution[/b] before that session unfolds: every expected high-volume level at once, not a single line.

It is not a moving average wearing a costume. Each finished session is treated as evidence: hundreds of particles are weighed against what actually traded, resampled, and mutated. Predict → observe → update, honestly Bayesian, every session.


🔹 [b]HOW IT WORKS[/b]

Two particle swarms run side by side:

 • A [b]shape swarm[/b] learns the form of the distribution; one lump or several, wide or tight, and where each volume node sits.
 • A [b]drift swarm[/b] learns how far from the open the session's center of gravity tends to land.

An empirical-Bayes trust term scales the drift forecast by how much it has actually earned: when its track record is poor, the forecast automatically hugs the open. The prediction you see is the shape swarm's density, re-anchored by the trusted fraction of the drift forecast, rendered through a kernel density estimate whose bandwidth follows Silverman's rule.


🔸 [b]HOW TO READ IT[/b]

 • [b]Session heatmap[/b] — the predicted density painted from the session open to the profile. A two-tone gradient split at the open; the tones swap roles across it, so each side mirrors the other. Bold color = expected business, fade = expected quiet.
 • [b]Mirrored profile[/b] — the forecast on the left, split bullish/bearish at the session open; the realized session volume on the right in a single neutral color. 
 • [b]Confidence honesty[/b] — the prediction's glow scales with the filter's live confidence. When it has been wrong lately, its side visibly goes quiet. The realized side never fades, because reality doesn't.
 • [b]Bias info box[/b] — seated between the halves: the share of predicted volume above vs below the open (🢁 / 🢃).
 • [b]Expected levels[/b] — dashed lines at the probability-weighted average predicted price of each half: the session's expected bull and bear magnets.
 • [b]HVN lines + POC[/b] — the predicted high-volume levels. The point of control always shows; the [i]HVN Threshold[/i] input is your dial between a few safe targets and every level worth watching.


🔹 [b]SELF-TUNING[/b]

Every statistical free parameter tunes itself from data: the KDE bandwidth (Silverman's rule for visual convenience), the observation noise, the swarms' search domain (tracks the observed session spread), the mutation rate (genetic adaptation), the scout rate (scales with recent error), and the center trust (regression shrinkage). The inputs you are given are visual preferences plus a compute preset. There is nothing statistical to fiddle with, on purpose.


🔸 [b]INPUTS[/b]

 • [i]Session Engine[/i] — Session Timeframe (the session boundary; must exceed the chart timeframe), Prediction Quality (particles per swarm, Fast 100 → Max 4000), Sessions to Keep.
 • [i]Volume Profile[/i] — toggles for the profile, bias box and expected levels; width, offset, info-box width, transparency.
 • [i]Session Heatmap[/i] — toggle, faint/bold density transparencies, Tone A / Tone B.
 • [i]High Volume Nodes[/i] — toggle, HVN Threshold %, reach, color.
 • [i]Colors[/i] — Bullish, Bearish, Realized.


🔹 [b]VALIDATION[/b]

The filter was tested on real intraday data; 10 large-cap symbols, three session horizons, every prediction one-step-ahead and out-of-sample, against uniform, yesterday's-profile, Gaussian-fit, rolling-average and EWMA baselines, with the test harness itself audited too.

 • Against naive prediction (uniform prior, yesterday's profile) it wins every metric tested at every horizon.
 • Against the strongest profile-averaging methods it trades wins: they edge the single-lump fit metrics; the filter captures materially more of the session's actual traded volume with its predicted levels, and is the only method that reliably names [b]multiple simultaneous targets[/b].
 • On sessions with two or more real volume peaks; roughly 4 in 10 sessions, its targets covered 19–42% more realized volume than the best alternative.


🔸 [b]LIMITATIONS AND HONEST NOTES[/b]

 • The forecast for a session is set when that session opens and is [b]not repainted[/b]; the realized half updates live as the session trades.
 • It estimates a [b]distribution of volume[/b], not a promise of direction. The bias %, expected levels and HVN set are probability-weighted readings of that distribution.
 • The filter is stochastic by nature: two chart reloads can differ in fine detail, the way two runs of any Monte Carlo method do. The structure it finds is stable; the pixel-level noise is not.
 • Requires volume data from your data feed. Not supported on non-standard chart types.
 • The chart timeframe must be lower than the session timeframe.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trading-IQ

//@version=6
indicator("IQ Session Bayesian Particle Filter [TradingIQ]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100, max_polylines_count = 100, calc_bars_count = 5000)

// HEAD {

// enums {

enum Preset
    fast = "Fast"
    balanced = "Balanced"
    precision = "Precision"
    extra = "Extra"
    max = "Max"

enum Reach
    sesh = "Current Session"
    chart = "Full Chart"

// enums }

// types {

type PRNG
    float seed = 12345678.0

type Particle
    float z
    float m
    float pn

type Swarm
    Particle[] particles
    float domain
    float error = 0.0

type Stats
    float avg_rnge = na
    float avg_spread = na
    float offset_scale = 0.25
    float confidence = 1.0
    float trust_cx = 0.0
    float trust_cc = 1e-6
    bool ready = false

type Session
    float open_price = na
    float high_price = na
    float low_price = na
    float vol = 0.0
    int start_index = 0
    float center = na
    float raw_offset = 0.0
    float min_z = na
    float max_z = na
    float bandwidth = 0.25
    float[] live
    float[] density

type BoxVec
    box[] boxes

type Drawings
    box[] backdrop
    BoxVec[] history
    polyline[] expected
    polyline[] realized
    box[] badge
    line[] levels
    line[] nodes
    label tag

type Config
    string timeframe
    int particles
    int history
    int bins

    bool show_profile
    int offset
    int width
    float profile_t

    bool show_bias
    bool show_levels
    int badge_width

    bool show_heatmap
    float heatmap_faint
    float heatmap_bold
    color heatmap_cool
    color heatmap_hot

    bool show_nodes
    float node_threshold
    Reach node_reach

    color bull_color
    color bear_color
    color realized_color
    color node_color

// types }

// helpers {

var const float i_sqrt_2pi = 0.3989422804014327
var const float mutation_base = 0.1
var const float mutation_scale = 8.0
var const float mutation_width = 0.5
var const float noise_floor = 0.01
var const float noise_ceiling = 1000.0
var const float base_noise = 0.01
var const float base_rnge = 1.0
var const float shape_limit = 0.5
var const float drift_limit = 0.5
var const float drift_noise = 0.2 // likelihood width for the session-center observation

// adaptive shape domain: the swarm clamp tracks the observed session spread
var const float domain_k = 1.6
var const float domain_lo = 0.45
var const float domain_hi = 1.5
var const float domain_alpha = 0.2

clamp(float source, float min, float max)=> math.max(math.min(source, max), min)

gauss(float distance, float sigma)=> math.exp(-0.5 * math.pow(distance / sigma, 2)) * i_sqrt_2pi / sigma

silverman(float sigma, int samples, float floor, float ceiling)=> clamp(1.06 * sigma * math.pow(samples, -0.2), floor, ceiling)

method scale_alpha(float self, float alpha = 80)=>
    float invert = 100 - alpha
    self * invert / 100

method new_alpha(color self, float alpha = 80)=>
    color.new(self, alpha + color.t(self).scale_alpha(alpha))

method to_extend(Reach self)=>
    switch self
        Reach.chart => extend.left
        => extend.none

VOID()=>
    if false
        log.info("void")

// helpers }

// rng {

var const float lcg_modulus = 4294967296.0
var const float lcg_multiplier = 1664525.0
var const float lcg_increment = 1013904223.0

method uniform(PRNG self)=>
    self.seed := (lcg_multiplier * self.seed + lcg_increment) % lcg_modulus
    self.seed / lcg_modulus

method gaussian(PRNG self, float sigma)=>
    float u1 = math.max(1e-6, self.uniform())
    float u2 = self.uniform()
    math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2) * sigma

// rng }

// swarm {

init_swarm(int particles, float domain, float spread, PRNG rng)=>
    Particle[] swarm = array.new<Particle>()
    float m = 1.0 / particles
    for int i = 0 to particles - 1
        swarm.push(Particle.new(clamp(rng.gaussian(spread), -domain, domain), m, base_noise))
    Swarm.new(swarm, domain)

method mean(Swarm self)=>
    float mean = 0.0
    for p in self.particles
        mean += p.z * p.m
    mean

method spread(Swarm self)=>
    float mean = self.mean()
    float variance = 0.0
    for p in self.particles
        variance += math.pow(p.z - mean, 2) * p.m
    math.sqrt(variance)

method bandwidth(Swarm self, float floor)=> silverman(self.spread(), self.particles.size(), floor, 1.0) // silverman's rule

method density(Swarm self, float z, float bandwidth)=>
    float density = 0.0
    for p in self.particles
        density += p.m * gauss(z - p.z, bandwidth)
    density

method weigh(Swarm self, float[] observation, float min_z, float step, float sigma)=>
    int n = self.particles.size()
    float total = observation.sum()
    float sum_m = 0.0
    bool starved = total <= 0

    if not starved
        int bins = observation.size()
        float i_total = 1.0 / total
        for p in self.particles
            float fitness = 0.0
            for int i = 0 to bins - 1
                float mass = observation.get(i)
                if mass > 0
                    float bin_z = min_z + (i + 0.5) * step
                    fitness += mass * i_total * gauss(bin_z - p.z, sigma) // mixture likelihood, constants cancel after normalization
            p.m := p.m * math.max(1e-10, fitness)
            sum_m += p.m
        starved := sum_m <= 1e-8

    for p in self.particles
        p.m := starved ? 1.0 / n : p.m / sum_m
    starved

method weigh(Swarm self, float observation, float sigma)=>
    float sum_m = 0.0
    for p in self.particles
        p.m := p.m * math.max(1e-10, gauss(observation - p.z, sigma))
        sum_m += p.m

    bool starved = sum_m <= 1e-8
    for p in self.particles
        p.m := starved ? 1.0 / self.particles.size() : p.m / sum_m
    starved

method evolve(Swarm self, PRNG rng, float scout_min, float scout_max, bool starved)=>
    int count = self.particles.size()
    float uniform_m = 1.0 / count

    float sum_sq = 0.0
    for p in self.particles
        sum_sq += math.pow(p.m, 2)
    float effective = sum_sq > 0 ? 1.0 / sum_sq : 0.0
    if starved
        effective := 0.0

    float mutation_rate = mutation_base * (1.0 + self.error * mutation_scale)
    float scout_chance = starved ? 1.0 : 0.05 + self.error * 0.20

    if effective < count / 2.0
        Particle[] fresh = array.new<Particle>()
        float step = uniform_m
        float u = rng.uniform() * step
        float cdf = self.particles.first().m
        int idx = 0

        for int i = 0 to count - 1
            while u > cdf and idx < count - 1
                idx += 1
                cdf += self.particles.get(idx).m

            Particle parent = self.particles.get(idx)
            float pn = clamp(parent.pn + rng.gaussian(mutation_width * mutation_rate), noise_floor, noise_ceiling)
            float z = na

            switch rng.uniform() < scout_chance
                true =>
                    z := clamp(rng.uniform() * (scout_max - scout_min) + scout_min, -self.domain, self.domain)
                    pn := base_noise
                false =>
                    z := clamp(parent.z + rng.gaussian(pn), -self.domain, self.domain)

            fresh.push(Particle.new(z, uniform_m, pn))
            u += step

        self.particles.clear()
        for p in fresh
            self.particles.push(p)
    else
        for p in self.particles // mutate in place to prevent filter freezing
            p.pn := clamp(p.pn + rng.gaussian(mutation_width * mutation_rate), noise_floor, noise_ceiling)
            p.z := clamp(p.z + rng.gaussian(p.pn), -self.domain, self.domain)
    self

// swarm }

// stats {

method rnge_unit(Stats self)=> math.max(syminfo.mintick, nz(self.avg_rnge, syminfo.mintick))

method shape_domain(Stats self, float spread)=>
    self.avg_spread := na(self.avg_spread) ? spread : self.avg_spread * (1 - domain_alpha) + spread * domain_alpha
    clamp(self.avg_spread * domain_k, domain_lo, domain_hi) // swarm clamp expands on wide days, contracts on tight ones

method trust(Stats self)=> clamp(self.trust_cx / math.max(self.trust_cc, 1e-9), 0.0, 1.0) // empirical-bayes shrinkage: trust the center forecast only as far as it has predicted well

method update(Stats self, Session sesh, float error, float offset)=>
    self.trust_cx := 0.8 * self.trust_cx + 0.2 * sesh.raw_offset * offset
    self.trust_cc := 0.8 * self.trust_cc + 0.2 * sesh.raw_offset * sesh.raw_offset
    float rnge = sesh.high_price - sesh.low_price
    switch self.ready
        false =>
            self.avg_rnge := rnge
            self.ready := true
        true =>
            float alpha = math.max(0.05, error) // memory shortens as predictions miss
            self.avg_rnge := self.avg_rnge * (1 - alpha) + rnge * alpha
            self.offset_scale := self.offset_scale * (1 - alpha) + math.abs(offset) * alpha
    self.confidence := 1.0 - error
    self

// stats }

// sesh data {

init_session(int bins)=>
    Session.new(live = array.new<float>(bins, 0.0), density = array.new<float>(bins, 0.0))

method step(Session self)=> (self.max_z - self.min_z) / self.live.size()

method begin(Session self, float center, int bins)=>
    self.open_price := open
    self.high_price := high
    self.low_price := low
    self.vol := 0.0
    self.start_index := bar_index
    self.center := center
    self.min_z := -base_rnge
    self.max_z := base_rnge
    self.live := array.new<float>(bins, 0.0)
    self.density := array.new<float>(bins, 0.0)
    self

method track(Session self)=>
    self.high_price := math.max(self.high_price, high)
    self.low_price := math.min(self.low_price, low)
    self.vol += nz(volume)
    self

method make_density(Session self, Swarm shp)=>
    float step = self.step()
    for int i = 0 to self.density.size() - 1
        float z = self.min_z + (i + 0.5) * step
        self.density.set(i, shp.density(z, self.bandwidth))
    self

method divergence(Session self)=>
    float density_total = self.density.sum()
    float live_total = self.live.sum()
    float divergence = 0.0
    if density_total > 0 and live_total > 0
        for int i = 0 to self.live.size() - 1
            divergence += math.abs(self.density.get(i) / density_total - self.live.get(i) / live_total)
        divergence := divergence / 2.0 // total variation distance, bound 0..1
    divergence

method spread(Session self)=>
    float step = self.step()
    float total = self.live.sum()
    float spread = step * 2.0
    if total > 0
        float i_total = 1.0 / total
        float mean = 0.0
        for int i = 0 to self.live.size() - 1
            mean += (self.min_z + (i + 0.5) * step) * self.live.get(i) * i_total
        float variance = 0.0
        for int i = 0 to self.live.size() - 1
            variance += math.pow(self.min_z + (i + 0.5) * step - mean, 2) * self.live.get(i) * i_total
        spread := math.sqrt(variance)
    spread

method occupied(Session self)=>
    int occupied = 0
    for int i = 0 to self.live.size() - 1
        occupied += self.live.get(i) > 0 ? 1 : 0
    occupied

method observation_noise(Session self)=> silverman(self.spread(), math.max(self.occupied(), 1), self.step(), 1.0)

method rasterize(Session self, Stats stats, Swarm shp)=>
    float unit = stats.rnge_unit()
    float step = self.step()
    float z_high = (high - self.center) / unit
    float z_low = (low - self.center) / unit
    float pad = (z_high - z_low) * 0.1

    bool resized = false
    float new_min = self.min_z
    float new_max = self.max_z
    if z_high > new_max
        new_max := z_high + pad
        resized := true
    if z_low < new_min
        new_min := z_low - pad
        resized := true

    int count = self.live.size()
    if resized
        float new_step = (new_max - new_min) / count
        float[] fresh = array.new<float>(count, 0.0)
        for int i = 0 to count - 1
            float mass = self.live.get(i)
            if mass > 0
                float z = self.min_z + (i + 0.5) * step
                int idx = int(clamp(math.floor((z - new_min) / new_step), 0, count - 1))
                fresh.set(idx, fresh.get(idx) + mass)
        self.live := fresh
        self.min_z := new_min
        self.max_z := new_max
        step := new_step
        self.make_density(shp)

    float clamped_high = clamp(z_high, self.min_z, self.max_z)
    float clamped_low = clamp(z_low, self.min_z, self.max_z)
    int top_idx = int(clamp(math.floor((clamped_high - self.min_z) / step), 0, count - 1))
    int bottom_idx = int(clamp(math.floor((clamped_low - self.min_z) / step), 0, count - 1))
    int first = math.min(top_idx, bottom_idx)
    int last = math.max(top_idx, bottom_idx)

    float amount = nz(volume)
    if amount > 0
        float share = amount / (last - first + 1)
        for int i = first to last
            self.live.set(i, self.live.get(i) + share)
    resized

// sesh data }

// drawing {

heatmap_color(Config config, float fraction, bool bullish)=>
    color faint_tone = bullish ? config.heatmap_hot : config.heatmap_cool
    color bold_tone = bullish ? config.heatmap_cool : config.heatmap_hot
    color.from_gradient(fraction, 0.0, 1.0, faint_tone.new_alpha(config.heatmap_faint), bold_tone.new_alpha(config.heatmap_bold))

price_at(Session sesh, Stats stats, float z)=> sesh.center + z * stats.rnge_unit()


profile_points(Session sesh, Stats stats, int axis, int sign, float[] values, float i_scale, float half, int from_bin, int to_bin)=>
    float step = sesh.step()
    chart.point[] points = array.new<chart.point>()

    float v0 = values.get(from_bin)
    int w0 = v0 > 0 ? math.max(1, int(math.round(v0 * i_scale * half))) : 0
    float baseline = price_at(sesh, stats, sesh.min_z + from_bin * step)
    points.push(chart.point.new(na, axis, baseline))
    points.push(chart.point.new(na, axis + sign * w0, baseline))

    int prev_w = w0
    for int i = from_bin to to_bin
        float top_i = price_at(sesh, stats, sesh.min_z + (i + 1) * step)
        points.push(chart.point.new(na, axis + sign * prev_w, top_i))
        if i < to_bin
            float v_next = values.get(i + 1)
            int w_next = v_next > 0 ? math.max(1, int(math.round(v_next * i_scale * half))) : 0
            points.push(chart.point.new(na, axis + sign * w_next, top_i))
            prev_w := w_next

    points.push(chart.point.new(na, axis, price_at(sesh, stats, sesh.min_z + (to_bin + 1) * step)))
    points


method glow(polyline[] self, chart.point[] points, color base, float scale)=>
    float[] widths = array.from(9.0, 6.0, 3.0)
    float[] alphas = array.from(90.0, 84.0, 76.0)
    for int j = 0 to widths.size() - 1
        self.push(polyline.new(points, curved = false, closed = false, xloc = xloc.bar_index, line_color = base.new_alpha(alphas.get(j)), fill_color = na, line_style = line.style_solid, line_width = math.max(1, int(math.round(widths.get(j) * scale)))))
    VOID()


method edge(polyline[] self, chart.point[] points, color base)=>
    self.push(polyline.new(points, curved = false, closed = false, xloc = xloc.bar_index, line_color = base, fill_color = na, line_style = line.style_solid, line_width = 1))
    VOID()


method paint(polyline[] self, chart.point[] points, color base, float fill_t)=>
    self.push(polyline.new(points, curved = false, closed = true, xloc = xloc.bar_index, line_color = base.new_alpha(fill_t), fill_color = base.new_alpha(fill_t), line_style = line.style_solid, line_width = 1))
    VOID()

init_drawings()=>
    var Drawings drawings = Drawings.new(
       array.new<box>()
     , array.new<BoxVec>()
     , array.new<polyline>()
     , array.new<polyline>()
     , array.new<box>()
     , array.new<line>()
     , array.new<line>()
     , label(na)
     )
    drawings

method kill(BoxVec self)=>
    while self.boxes.size() > 0
        self.boxes.pop().delete()
    VOID()

method trim(BoxVec[] self, int max)=>
    while self.size() > max
        self.pop().kill()
    VOID()

method drain(Drawings self)=>
    while self.expected.size() > 0
        self.expected.pop().delete()
    while self.realized.size() > 0
        self.realized.pop().delete()
    while self.badge.size() > 0
        self.badge.pop().delete()
    while self.levels.size() > 0
        self.levels.pop().delete()
    while self.nodes.size() > 0
        self.nodes.pop().delete()
    if not na(self.tag)
        self.tag.delete()
    self

method retire(Drawings self, Config config)=>
    for b in self.backdrop
        b.set_right(bar_index - 1)
    self.history.unshift(BoxVec.new(self.backdrop))
    self.backdrop := array.new<box>()
    self.history.trim(config.history)
    self.drain()

method build_grid(Drawings self, Session sesh, Stats stats, Config config)=>
    self.tag := label.new(sesh.start_index, sesh.open_price, config.timeframe, color = #00000000, textcolor = color.gray, style = label.style_label_down, size = size.small)
    if config.show_heatmap
        float step = sesh.step()
        float max_density = math.max(sesh.density.max(), 1e-10)
        float z_open = (sesh.open_price - sesh.center) / stats.rnge_unit()
        for int i = 0 to sesh.density.size() - 1
            float z = sesh.min_z + (i + 0.5) * step
            color shade = heatmap_color(config, sesh.density.get(i) / max_density, z >= z_open)
            self.backdrop.push(box.new(sesh.start_index, price_at(sesh, stats, z + step * 0.5), sesh.start_index, price_at(sesh, stats, z - step * 0.5), border_color = na, bgcolor = shade))
    self

method rebuild_grid(Drawings self, Session sesh, Stats stats, Config config)=>
    float step = sesh.step()
    float max_density = math.max(sesh.density.max(), 1e-10)
    float z_open = (sesh.open_price - sesh.center) / stats.rnge_unit()
    for int i = 0 to sesh.density.size() - 1
        float z = sesh.min_z + (i + 0.5) * step
        if self.backdrop.size() > i
            box b = self.backdrop.get(i)
            b.set_top(price_at(sesh, stats, z + step * 0.5))
            b.set_bottom(price_at(sesh, stats, z - step * 0.5))
            b.set_bgcolor(heatmap_color(config, sesh.density.get(i) / max_density, z >= z_open))
    self

method draw_nodes(Drawings self, Session sesh, Stats stats, Config config, int axis)=>
    while self.nodes.size() > 0
        self.nodes.pop().delete()

    if config.show_nodes
        int bins = sesh.density.size()
        float step = sesh.step()
        float threshold = sesh.density.max() * config.node_threshold
        string reach = config.node_reach.to_extend()
        int poc_idx = sesh.density.indexof(sesh.density.max()) // the single most likely price level, always shown regardless of threshold

        float[] node_widths = array.from(13.0, 10.0, 7.0, 4.0)
        float[] poc_widths = array.from(17.0, 13.0, 9.0, 5.0)
        float[] halo_alphas = array.from(92.0, 86.0, 78.0, 68.0)

        for int i = 0 to bins - 1
            float here = sesh.density.get(i)
            bool is_poc = i == poc_idx
            bool node = not is_poc and here >= threshold
              and (i == 0 or sesh.density.get(i - 1) < here)
              and (i == bins - 1 or sesh.density.get(i + 1) <= here)

            if (node or is_poc) and self.nodes.size() <= 490 // five lines per node; headroom for the expected-level pairs
                float price = price_at(sesh, stats, sesh.min_z + (i + 0.5) * step)
                float[] widths = is_poc ? poc_widths : node_widths
                for int j = 0 to widths.size() - 1 // node glow fades as confidence drops
                    int w = math.max(1, int(math.round(widths.get(j) * stats.confidence)))
                    self.nodes.push(line.new(sesh.start_index, price, axis, price, color = config.node_color.new_alpha(halo_alphas.get(j)), width = w, extend = reach))
                self.nodes.push(line.new(sesh.start_index, price, axis, price, color = config.node_color, width = 1, extend = reach))
    self

method draw_badge(Drawings self, Session sesh, Stats stats, Config config, int left_axis, int right_axis, int split)=>
    float total = sesh.density.sum()
    if total > 0
        int bins = sesh.density.size()
        float bull_mass = 0.0
        if split < bins
            for int i = split to bins - 1
                bull_mass += sesh.density.get(i)
        float bull_frac = bull_mass / total

        float top = price_at(sesh, stats, sesh.max_z)
        float bottom = price_at(sesh, stats, sesh.min_z)
        float divide = bottom + (top - bottom) * (1.0 - bull_frac)
        string bull_text = "🢁\n\n" + str.tostring(math.round(bull_frac * 100.0, 1)) + "%"
        string bear_text = str.tostring(math.round((1.0 - bull_frac) * 100.0, 1)) + "%" + "\n\n🢃"

        self.badge.push(box.new(left_axis, top, right_axis, divide, border_color = na, bgcolor = config.bull_color.new_alpha(config.profile_t), text = bull_text, text_color = #FFFFFF, text_size = size.normal))
        self.badge.push(box.new(left_axis, divide, right_axis, bottom, border_color = na, bgcolor = config.bear_color.new_alpha(config.profile_t), text = bear_text, text_color = #FFFFFF, text_size = size.normal))
    self

method draw_levels(Drawings self, Session sesh, Stats stats, Config config, int axis, int split)=>
    int bins = sesh.density.size()
    float step = sesh.step()
    string reach = config.node_reach.to_extend()
    int width = math.max(1, int(math.round(2 * stats.confidence)))

    float bull_mass = 0.0
    float bull_moment = 0.0
    float bear_mass = 0.0
    float bear_moment = 0.0
    for int i = 0 to bins - 1
        float mass = sesh.density.get(i)
        float price = price_at(sesh, stats, sesh.min_z + (i + 0.5) * step)
        switch i >= split
            true =>
                bull_mass += mass
                bull_moment += mass * price
            false =>
                bear_mass += mass
                bear_moment += mass * price

    if bull_mass > 0
        float bull_level = bull_moment / bull_mass
        self.levels.push(line.new(sesh.start_index, bull_level, axis, bull_level, color = config.bull_color.new_alpha(88), style = line.style_solid, width = width + 4, extend = reach)) // a translucent solid bed under the dash, so the level subtly glows
        self.levels.push(line.new(sesh.start_index, bull_level, axis, bull_level, color = config.bull_color, style = line.style_dashed, width = width, extend = reach))
    if bear_mass > 0
        float bear_level = bear_moment / bear_mass
        self.levels.push(line.new(sesh.start_index, bear_level, axis, bear_level, color = config.bear_color.new_alpha(88), style = line.style_solid, width = width + 4, extend = reach))
        self.levels.push(line.new(sesh.start_index, bear_level, axis, bear_level, color = config.bear_color, style = line.style_dashed, width = width, extend = reach))
    self

method draw_profile(Drawings self, Session sesh, Stats stats, Config config)=>
    if barstate.islast
        int gap = config.show_bias ? config.badge_width : 0 
        int axis = bar_index + config.offset + int(math.round(config.width / 2.0)) // the prediction's baseline
        int realized_axis = axis + gap

        for b in self.backdrop
            b.set_right(axis)

        while self.expected.size() > 0
            self.expected.pop().delete()
        while self.realized.size() > 0
            self.realized.pop().delete()
        while self.badge.size() > 0
            self.badge.pop().delete()
        while self.levels.size() > 0
            self.levels.pop().delete()

        int bins = sesh.live.size()
        float step = sesh.step()
        float z_open = (sesh.open_price - sesh.center) / stats.rnge_unit()
        int split = int(clamp(math.ceil((z_open - sesh.min_z) / step - 0.5), 0, bins)) // first bin whose center sits at or above the open

        if config.show_profile
            float half = config.width / 2.0
            float i_expected = 1.0 / math.max(1e-10, sesh.density.max())
            float i_realized = 1.0 / math.max(1e-10, sesh.live.max())

            chart.point[] outline = profile_points(sesh, stats, axis, -1, sesh.density, i_expected, half, 0, bins - 1)
            chart.point[] mirror = profile_points(sesh, stats, realized_axis, 1, sesh.live, i_realized, half, 0, bins - 1)
            chart.point roof = chart.point.new(na, realized_axis, price_at(sesh, stats, sesh.max_z))
            chart.point sill = chart.point.new(na, realized_axis, price_at(sesh, stats, sesh.min_z))

            int cut = split <= 0 ? -1 : split >= bins ? outline.size() : 2 * split + 1 // hand-off index at the open; pushed off either end when one half owns the whole outline
            chart.point[] bear_border = array.new<chart.point>()
            chart.point[] bull_border = array.new<chart.point>()
            for int i = 0 to outline.size() - 1
                if i <= cut
                    bear_border.push(outline.get(i))
                if i >= cut
                    bull_border.push(outline.get(i))
            chart.point[] head_border = split > 0 ? bear_border : bull_border // the perimeter walk runs floor -> outline -> roof
            chart.point[] tail_border = split < bins ? bull_border : bear_border
            head_border.unshift(sill)
            tail_border.push(roof)

            if bear_border.size() >= 2 // the prediction's halo fades with confidence
                self.expected.glow(bear_border, config.bear_color, stats.confidence)
            if bull_border.size() >= 2
                self.expected.glow(bull_border, config.bull_color, stats.confidence)
            self.realized.glow(mirror, config.realized_color, 1.0) 

            if split > 0 
                self.expected.paint(profile_points(sesh, stats, axis, -1, sesh.density, i_expected, half, 0, split - 1), config.bear_color, config.profile_t)
            if split < bins
                self.expected.paint(profile_points(sesh, stats, axis, -1, sesh.density, i_expected, half, split, bins - 1), config.bull_color, config.profile_t)
            self.realized.paint(mirror, config.realized_color, config.profile_t)

            if bear_border.size() >= 2
                self.expected.edge(bear_border, config.bear_color)
            if bull_border.size() >= 2
                self.expected.edge(bull_border, config.bull_color)
            self.realized.edge(mirror, config.realized_color)

        if config.show_bias
            self.draw_badge(sesh, stats, config, axis, realized_axis, split)
        if config.show_levels
            self.draw_levels(sesh, stats, config, axis, split)

        self.draw_nodes(sesh, stats, config, axis)
    self

// drawing }

// main {

main(Config config)=>
    var PRNG rng = PRNG.new()
    var Stats stats = Stats.new()
    var Swarm shp = init_swarm(config.particles, shape_limit, base_rnge * 0.5, rng)
    var Swarm drift = init_swarm(config.particles, drift_limit, 0.0, rng)
    var Session sesh = init_session(config.bins)
    var Drawings drawings = init_drawings()

    bool new_session = timeframe.change(config.timeframe) or barstate.isfirst

    if new_session
        if not barstate.isfirst and sesh.vol > 0
            float unit = stats.rnge_unit()
            float true_offset = (math.avg(sesh.high_price, sesh.low_price) - sesh.open_price) / unit

            if stats.ready
                bool shape_starved = shp.weigh(sesh.live, sesh.min_z, sesh.step(), sesh.observation_noise())
                bool drift_starved = drift.weigh(true_offset, drift_noise)

                shp.error := sesh.divergence()
                drift.error := clamp(math.abs(sesh.raw_offset - true_offset) / 2.0, 0.0, 1.0) // scored on the raw forecast, so the swarm's own adaptation is not muted by shrinkage

                shp.domain := stats.shape_domain(sesh.spread()) // adaptive clamp, tracked from the observed session spread
                shp.evolve(rng, -shp.domain, shp.domain, shape_starved)
                float scout = clamp(stats.offset_scale * 3.0, 0.1, drift_limit)
                drift.evolve(rng, -scout, scout, drift_starved)

            stats.update(sesh, math.max(shp.error, drift.error), true_offset)

        drawings.retire(config)
        float raw_offset = drift.mean()
        float center = stats.ready ? open + stats.trust() * raw_offset * stats.rnge_unit() : open
        sesh.begin(center, config.bins)
        sesh.raw_offset := raw_offset
        if stats.ready
            sesh.bandwidth := shp.bandwidth(sesh.step())
            sesh.make_density(shp)
            drawings.build_grid(sesh, stats, config)

    sesh.track()
    if stats.ready
        if sesh.rasterize(stats, shp)
            drawings.rebuild_grid(sesh, stats, config)
        drawings.draw_profile(sesh, stats, config)

    VOID()

// main }

// HEAD }


// BODY {

// inputs {

// { engine
var const string engine_group = "Session Engine"

const string timeframe_tip = "The session boundary, each new bar of this timeframe starts a fresh prediction. Must be higher than the chart timeframe."
const string quality_tip = "Particles per swarm. More particles resolve finer detail at the cost of load time; the filter self-tunes otherwise."
const string history_tip = "How many finished session heatmaps stay on the chart behind price. Grid resolution adapts automatically to stay within TradingView's drawing budget."

string session_timeframe = input.timeframe("D", "Session Timeframe", tooltip = timeframe_tip, group = engine_group)
var Preset quality = input.enum(Preset.balanced, "Prediction Quality", tooltip = quality_tip, group = engine_group)
int sessions_kept = input.int(0, "Sessions to Keep", minval = 0, maxval = 8, tooltip = history_tip, group = engine_group)
// } engine

// { profile
var const string profile_group = "Volume Profile"

const string profile_tip = "The mirrored profile to the right of price: predicted distribution on the left, split bullish/bearish at the session open; realized session volume on the right in a single color. Each side is scaled to its own peak."
const string bias_tip = "An info box seated between the two histogram halves, showing what share of the predicted volume sits above (bull) versus below (bear) the session open. Hiding it closes the gap."
const string badge_width_tip = "Width of the bias info box, in bars. The prediction anchors to its left edge and the realized volume to its right edge."
const string levels_tip = "Dashed lines at the probability-weighted average predicted price of each half, the expected bull level and expected bear level for the session."

bool show_profile = input.bool(true, "Show Volume Profile", tooltip = profile_tip, group = profile_group)
bool show_bias = input.bool(true, "Show Bias Badge", tooltip = bias_tip, group = profile_group)
bool show_levels = input.bool(true, "Show Expected Levels", tooltip = levels_tip, group = profile_group)
int profile_width = input.int(30, "Profile Width", minval = 5, maxval = 200, group = profile_group)
int profile_offset = input.int(2, "Profile Offset", minval = 0, maxval = 100, group = profile_group)
int badge_width = input.int(3, "Info Box Width", minval = 2, maxval = 30, tooltip = badge_width_tip, group = profile_group)
float profile_transparency = input.float(60.0, "Profile Transparency", minval = 0, maxval = 100, group = profile_group)
// } profile

// { heatmap
var const string heatmap_group = "Session Heatmap"

const string heatmap_tip = "The predicted volume density painted behind price, from open to now, a two-tone gradient split at the session open, where the tones swap roles on the opposite side. Low density fades toward transparent, high density turns bold."
const string tone_a_tip = "Above the open: the bold high-density tone. Below the open: the faint low-density tone."
const string tone_b_tip = "Above the open: the faint low-density tone. Below the open: the bold high-density tone."

bool show_heatmap = input.bool(true, "Show Session Heatmap", tooltip = heatmap_tip, group = heatmap_group)
float heatmap_faint = input.float(95.0, "Faintest (Low Density)", minval = 0, maxval = 100, group = heatmap_group)
float heatmap_bold = input.float(80.0, "Boldest (High Density)", minval = 0, maxval = 100, group = heatmap_group)
color heatmap_cool = input.color(#54aaee, "Tone A", tooltip = tone_a_tip, group = heatmap_group)
color heatmap_hot = input.color(#b051c8, "Tone B", tooltip = tone_b_tip, group = heatmap_group)
// } heatmap

// { nodes
var const string node_group = "High Volume Nodes"

const string node_tip = "A price level is flagged as an expected HVN when its predicted density reaches this percent of the session's peak density. The single most likely level (the predicted point of control) always shows, with an extra glow, regardless of this threshold."

bool show_nodes = input.bool(true, "Show HVN Lines", group = node_group)
float node_threshold = input.float(5.0, "HVN Threshold %", minval = 5.0, maxval = 100.0, step = 5.0, tooltip = node_tip, group = node_group)
var Reach node_reach = input.enum(Reach.sesh, "HVN Reach", group = node_group)
color node_color = input.color(#a8bdce, "HVN Color", group = node_group)
// } nodes

// { colors
var const string color_group = "Colors"

color bull_color = input.color(#54aaee, "Bullish", tooltip = "The prediction at or above the session open: profile half, badge, expected level.", group = color_group)
color bear_color = input.color(#b051c8, "Bearish", tooltip = "The prediction below the session open: profile half, badge, expected level.", group = color_group)
color realized_color = input.color(#a8bdce, "Realized", tooltip = "Actual session volume (the right half of the profile); one color, complementing the prediction pair.", group = color_group)
// } colors

int particles = switch quality
    Preset.fast => 100
    Preset.balanced => 500
    Preset.precision => 1000
    Preset.extra => 2000
    Preset.max => 4000
    => 50

int bins = int(math.min(200, 498 / (1 + sessions_kept))) // 500-box budget: one backdrop box per bin for the live session plus each kept session, and two for the bias badge

var Config config = Config.new(
   session_timeframe
 , particles
 , sessions_kept
 , bins

 , show_profile
 , profile_offset
 , profile_width
 , profile_transparency

 , show_bias
 , show_levels
 , badge_width

 , show_heatmap
 , heatmap_faint
 , heatmap_bold
 , heatmap_cool
 , heatmap_hot

 , show_nodes
 , node_threshold * 0.01
 , node_reach

 , bull_color
 , bear_color
 , realized_color
 , node_color
 )

// inputs }

// calculations {

main(config)

// calculations }

// errors {

if barstate.isfirst
    if timeframe.in_seconds() >= timeframe.in_seconds(session_timeframe)
        runtime.error("The chart timeframe must be lower than the session timeframe (" + session_timeframe + "). Lower the chart timeframe or raise the session timeframe.")

float has_volume = ta.cum(nz(volume))
if barstate.islast
    if has_volume == 0
        runtime.error("This symbol has no volume data. The particle filter needs volume to build a distribution.")

// errors }
// BODY }
````
