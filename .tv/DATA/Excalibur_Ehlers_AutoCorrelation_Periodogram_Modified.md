<!-- tradingview-pine-id: PUB;d1eb259674e64b90ad951720bd35ac68 -->
<!-- tradingviewscripts-format: 1 -->
# [Excalibur] Ehlers AutoCorrelation Periodogram Modified

Source: https://www.tradingview.com/script/MdtqpNT0-Excalibur-Ehlers-AutoCorrelation-Periodogram-Modified/

## Description

Keep your coins folks, I don't need them, don't want them. If you wish be generous, I do hope that charitable peoples worldwide with surplus food stocks may consider stocking local food banks before stuffing monetary bank vaults, for the crusade of remedying the needs of less than fortunate children, parents, elderly, homeless veterans, and everyone else who deserves nutritional sustenance for the soul.

DEDICATION:
This script is dedicated to the memory of Nikolai Dmitriyevich Kondratiev (Никола́й Дми́триевич Кондра́тьев) as tribute for being a pioneering economist and statistician, paving the way for modern econometrics by advocation of rigorous and empirical methodologies. One of his most substantial contributions to the study of business cycle theory include a revolutionary hypothesis recognizing the existence of dynamic cycle-like phenomenon inherent to economies that are characterized by distinct phases of expansion, stagnation, recession and recovery, what we now know as "Kondratiev Waves" (K-waves). Kondratiev was one of the first economists to recognize the vital significance of applying quantitative analysis on empirical data to evaluate economic dynamics by means of statistical methods. His understanding was that conceptual models alone were insufficient to adequately interpret real-world economic conditions, and that sophisticated analysis was necessary to better comprehend the nature of trending/cycling economic behaviors. Additionally, he recognized prosperous economic cycles were predominantly driven by a combination of technological innovations and infrastructure investments that resulted in profound implications for economic growth and development.

I will mention this... nation's economies MUST be supported and defended to continuously evolve incrementally in order to flourish in perpetuity OR suffer through eras with lasting ramifications of societal stagnation and implosion.

Analogous to the realm of economics, aperiodic cycles/frequencies, both enduring and ephemeral, do exist in all facets of life, every second of every day. To name a few that any blind man can naturally see are: heartbeat (cardiac cycles), respiration rates, circadian rhythms of sleep, powerful magnetic solar cycles, seasonal cycles, lunar cycles, weather patterns, vegetative growth cycles, and ocean waves. Do not pretend for one second that these basic aforementioned examples do not affect business cycle fluctuations in minuscule and monumental ways hour to hour, day to day, season to season, year to year, and decade to decade in every nation on the planet. Kondratiev's original seminal theories in macroeconomics from nearly a century ago have proven remarkably prescient with many of his antiquated elementary observations/notions/hypotheses in macroeconomics being scholastically studied and topically researched further. Therefore, I am compelled to honor and recognize his statistical insight and foresight.

If only.. Kondratiev could hold a pocket sized computer in the cup of both hands bearing the TradingView logo and platform services, I truly believe he would be amazed in marvelous delight with a GARGANTUAN smile on his face.

INTRODUCTION:
Firstly, this is NOT technically speaking an indicator like most others. I would describe it as an advanced cycle period detector to obtain market data spectral estimates with low latency and moderate frequency resolution. Developers can take advantage of this detector by creating scripts that utilize a "Dominant Cycle Source" input to adaptively govern algorithms. Be forewarned, I would only recommend this for advanced developers, not novice code dabbling. Although, there is some Pine wizardry introduced here for novice Pine enthusiasts to witness and learn from. AI did describe the code into one super-crunched sentence as, "a rare feat of exceptionally formatted code masterfully balancing visual clarity, precision, and complexity to provide immense educational value for both programming newcomers and expert Pine coders alike."

Understand all of the above aforementioned? Buckle up and proceed for a lengthy read of verbose complexity...

This is my enhanced and heavily modified version of autocorrelation periodogram (ACP) for Pine Script v5.0. It was originally devised by the mathemagician John Ehlers for detecting dominant cycles (frequencies) in an asset's price action. I have been sitting on code similar to this for a long time, but I decided to unleash the advanced code with my [Excalibur] fashion. Originally Ehlers released this with multiple versions, one in a 2016 TASC article and the other in his last published 2013 book "Cycle Analytics for Traders", chapter 8. He wasn't joking about "concepts of advanced technical trading" and ACP is nowhere near to his most intimidating and ingenious calculations in code. I will say the book goes into many finer details about the original periodogram, so if you wish to delve into even more elaborate info regarding Ehlers' original ACP form AND how you may adapt algorithms, you'll have to obtain one. Note to reader, comparing Ehlers' original code to my chimeric code embracing the "Power of Pine", you will notice they have little resemblance.

What you see is a new species of autocorrelation periodogram combining Ehlers' innovation with my fascinations of what ACP could be in a Pine package. One other intention of this script's code is to pay homage to Ehlers' lifelong works. Like Kondratiev, Ehlers is also a hardcore cycle enthusiast. I intend to carry on the fire Ehlers envisioned and I believe that is literally displayed here as a pleasant "fiery" example endowed with Pine. With that said, I tried to make the code as computationally efficient as possible, without going into dozens of more crazy lines of code to speed things up even more. There's also a few creative modifications I made by making alterations to the originating formulas that I felt were improvements, one of them being lag reduction. By recently questioning every single thing I thought I knew about ACP, combined with the accumulation of my current knowledge base, this is the innovative revision I came up with. I could have improved it more but decided not to mind thrash too many TV members, maybe later... 

I am now confident Pine should have adequate overhead left over to attach various indicators to the dominant cycle via input.source(). TV, I apologize in advance if in the future a server cluster combusts into a raging inferno... Coders, be fully prepared to build entire algorithms from pure raw code, because not all of the built-in Pine functions fully support dynamic periods (e.g. length=ANYTHING). Many of them do, as this was requested and granted a while ago, but some functions are just inherently finicky due to implementation combinations and MUST be emulated via raw code. I would imagine some comprehensive library or numerous authored scripts have portions of raw code for Pine built-ins some where on TV if you look diligently enough.

Notice: Unfortunately, I will not provide any integration support into member's projects at all. I have my own projects that require way too much of my day already. While I was refactoring my life (forgoing many other "important" endeavors) in the early half of 2023, I primarily focused on this code over and over in my surplus time. During that same time I was working on other innovations that are far above and beyond what this code is. I hope you understand.

The best way programmatically may be to incorporate this code into your private Pine project directly, after brutal testing of course, but that may be too challenging for many in early development. Being able to see the periodogram is also beneficial, so input sourcing may be the "better" avenue to tether portions of the dominant cycle to algorithms. Unique indication being able to utilize the dominantCycle may be advantageous when tethering this script to those algorithms. The easiest way is to manually set your indicators to what ACP recognizes as the dominant cycle, but that's actually not considered dynamic real time adaption of an indicator. Different indicators may need a proportion of the dominantCycle, say half it's value, while others may need the full value of it. That's up to you to figure that out in practice. Sourcing one or more custom indicators dynamically to one detector's dominantCycle may require code like this: `int sourceDC = int(math.max(6, math.min(49, input.source(close, "Dominant Cycle Source"))))`. Keep in mind, some algos can use a float, while algos with a for loop require an integer.

I have witnessed a few attempts by talented TV members for a Pine based autocorrelation periodogram, but not in this caliber. Trust me, coding ACP is no ordinary task to accomplish in Pine and modifying it blessed with applicable improvements is even more challenging. For over 4 years, I have been slowly improving this code here and there randomly. It is beautiful just like a real flame, but... this one can still burn you! My mind was fried to charcoal black a few times wrestling with it in the distant past. My very first attempt at translating ACP was a month long endeavor because PSv3 simply didn't have arrays back then. Anyways, this is ACP with a newer engine, I hope you enjoy it. Any TV subscriber can utilize this code as they please. If you are capable of sufficiently using it properly, please use it wisely with intended good will. That is all I beg of you.

Lastly, you now see how I have rasterized my Pine with Ehlers' swami-like tech. Yep, this whole time I have been using hline() since PSv3, not plot(). Evidently, plot() still has a deficiency limited to only 32 plots when it comes to creating intense eye candy indicators, the last I checked. The use of hline() is the optimal choice for rasterizing Ehlers styled heatmaps. This does only contain two color schemes of the many I have formerly created, but that's all that is essentially needed for this gizmo. Anything else is generally for a spectacle or seeing how brutal Pine can be color treated. The real hurdle is being able to manipulate colors dynamically with Merlin like capabilities from multiple algo results. That's the true challenging part of these heatmap contraptions to obtain multi-colored "predator vision" level indication. You now have basic hline() food for thought empowerment to wield as you can imaginatively dream in Pine projects.

PERIODOGRAM UTILITY IN REAL WORLD SCENARIOS:
This code is a testament to the abilities that have yet to be fully realized with indication advancements. Periodograms, spectrograms, and heatmaps are a powerful tool with real-world applications in various fields such as financial markets, electrical engineering, astronomy, seismology, and neuro/medical applications. For instance, among these diverse fields, it may help traders and investors identify market cycles/periodicities in financial markets, support engineers in optimizing electrical or acoustic systems, aid astronomers in understanding celestial object attributes, assist seismologists with predicting earthquake risks, help medical researchers with neurological disorder identification, and detection of asymptomatic cardiovascular clotting in the vaxxed via full body thermography. In either field of study, technologies in likeness to periodograms may very well provide us with a better sliver of analysis beyond what was ever formerly invented. Periodograms can identify dominant cycles and frequency components in data, which may provide valuable insights and possibly provide better-informed decisions. By utilizing periodograms within aspects of market analytics, individuals and organizations can potentially refrain from making blinded decisions and leverage data-driven insights instead.

PERIODOGRAM INTERPRETATION:
The periodogram renders the power spectrum of a signal, with the y-axis representing the periodicity (frequencies/wavelengths) and the x-axis representing time. The y-axis is divided into periods, with each elevation representing a period. In this periodogram, the y-axis ranges from 6 at the very bottom to 49 at the top, with intermediate values in between, all indicating the power of the corresponding frequency component by color. The higher the position occurs on the y-axis, the longer the period or lower the frequency. The x-axis of the periodogram represents time and is divided into equal intervals, with each vertical column on the axis corresponding to the time interval when the signal was measured. The most recent values/colors are on the right side.

The intensity of the colors on the periodogram indicate the power level of the corresponding frequency or period. The fire color scheme is distinctly like the heat intensity from any casual flame witnessed in a small fire from a lighter, match, or camp fire. The most intense power would be indicated by the brightest of yellow, while the lowest power would be indicated by the darkest shade of red or just black. By analyzing the pattern of colors across different periods, one may gain insights into the dominant frequency components of the signal and visually identify recurring cycles/patterns of periodicity.

SETTINGS CONFIGURATIONS BRIEFLY EXPLAINED:
Source Options: These settings allow you to choose the data source for the analysis. Using the `Source` selection, you may tether to additional data streams (e.g. close, hlcc4, hl2), which also may include samples from any other indicator. For example, this could be my "Chirped Sine Wave Generator" script found in my member profile. By using the `SineWave` selection, you may analyze a theoretical sinusoidal wave with a user-defined period, something already incorporated into the code. The `SineWave` will be displayed over top of the periodogram.

Roofing Filter Options: These inputs control the range of the passband for ACP to analyze. Ehlers had two versions of his highpass filters for his releases, so I included an option for you to see the obvious difference when performing a comparison of both. You may choose between 1st and 2nd order high-pass filters.

Spectral Controls: These settings control the core functionality of the spectral analysis results. You can adjust the autocorrelation lag, adjust the level of smoothing for Fourier coefficients, and control the contrast/behavior of the heatmap displaying the power spectra. I provided two color schemes by checking or unchecking a checkbox.

Dominant Cycle Options: These settings allow you to customize the various types of dominant cycle values. You can choose between floating-point and integer values, and select the rounding method used to derive the final dominantCycle values. Also, you may control the level of smoothing applied to the dominant cycle values.

DOMINANT CYCLE VALUE SELECTIONS:
External to the acs() function, the code takes a dominant cycle value returned from acs() and changes its numeric form based on a specified type and form chosen within the indicator settings. The dominant cycle value can be represented as an integer or a decimal number, depending on the attached algorithm's requirements. For example, FIR filters will require an integer while many IIR filters can use a float. The float forms can be either rounded, smoothed, or floored. If the resulting value is desired to be an integer, it can be rounded up/down or just be in an integer form, depending on how your algorithm may utilize it.

AUTOCORRELATION SPECTRUM FUNCTION BASICALLY EXPLAINED:
In the beginning of the acs() code, the population of caches for precalculated angular frequency factors and smoothing coefficients occur. By precalculating these factors/coefs only once and then storing them in an array, the indicator can save time and computational resources when performing subsequent calculations that require them later.

In the following code block, the "Calculate AutoCorrelations" is calculated for each period within the passband width. The calculation involves numerous summations of values extracted from the roofing filter. Finally, a correlation values array is populated with the resulting values, which are normalized correlation coefficients.

Moving on to the next block of code, labeled "Decompose Fourier Components", Fourier decomposition is performed on the autocorrelation coefficients. It iterates this time through the applicable period range of 6 to 49, calculating the real and imaginary parts of the Fourier components. Frequencies 6 to 49 are the primary focus of interest for this periodogram. Using the precalculated angular frequency factors, the resulting real and imaginary parts are then utilized to calculate the spectral Fourier components, which are stored in an array for later use.

The next section of code smooths the noise ridden Fourier components between the periods of 6 and 49 with a selected filter. This species also employs numerous SuperSmoothers to condition noisy Fourier components. One of the big differences is Ehlers' versions used basic EMAs in this section of code. I decided to add SuperSmoothers.

The final sections of the acs() code determines the peak power component for normalization and then computes the dominant cycle period from the smoothed Fourier components. It first identifies a single spectral component with the highest power value and then assigns it as the peak power. Next, it normalizes the spectral components using the peak power value as a denominator. It then calculates the average dominant cycle period from the normalized spectral components using Ehlers' "Center of Gravity" calculation. Finally, the function returns the dominant cycle period along with the normalized spectral components for later external use to plot the periodogram.

POST SCRIPT:
Concluding, I have to acknowledge a newly found analyst for assistance that I couldn't receive from anywhere else. For one, Claude doesn't know much about Pine, is unfortunately color blind, and can't even see the Pine reference, but it was able to intuitively shred my code with laser precise realizations. Not only that, formulating and reformulating my description needed crucial finesse applied to it, and I couldn't have provided what you have read here without that artificial insight. Finding the right order of words to convey the complexity of ACP and the elaborate accompanying content was a daunting task. No code in my life has ever absorbed so much time and hard fricking work, than what you witness here, an ACP gem cut pristinely. I'm unveiling my version of ACP for an empowering cause, in the hopes a future global army of code wielders will tether it to highly functional computational contraptions they might possess. Here is ACP fully blessed poetically with the "Power of Pine" in sublime code. ENJOY!

---

## Source Code

````pine
//@version=5
indicator('[Excalibur] Ehlers AutoCorrelation Periodogram Modified', 'EACPM', false, format.price, 1)

colorize(series float power,
         simple  bool originalColorScheme) =>
    // Heatmap Color Helper Function
    int red = 255
    int grn = 0
    if power > 0.5
        grn := int(510.0 * (power - 0.5))
    else
        red := int(510.0 * power)
    if grn == 255
        color.rgb(red, grn, 180)
    else
        if originalColorScheme
            color.rgb(red, grn, 0)
        else
            if power > 0.5
                color.rgb(grn, grn, 255 - grn)
            else
                color.rgb(grn, 0, red)

hp1st(series float Series,
      simple float Period) =>
    // John Ehlers' 1st Order High Pass Function
    var float afreq =  2.0 * math.pi / Period
    var float coef1 = (1.0 - math.sin(afreq)) / math.cos(afreq)
    var float coef0 = (1.0 + coef1) * 0.5
    float mom = Series - nz(Series[1], Series)
    float  HP = na, HP := coef0 *    mom +
                          coef1 * nz(HP[1])

hp2nd(series float Series,
      simple float Period) =>
    // John Ehlers' 2nd Order High Pass Function
    var float afreq =  math.sqrt( 2.0) * math.pi / Period
    var float alpha = (math.cos(afreq) + math.sin(afreq) - 1.0) / math.cos(afreq)
    var float coef0 =  math.pow(1.0 - alpha  / 2.0, 2.0)
    var float coef1 =          (1.0 - alpha) * 2.0
    var float coef2 =  math.pow(1.0 - alpha,   2.0)
    float series1 = nz(Series[1], Series)
    float whiten  =   (Series - 2.0 * series1 + nz(Series[2], series1))
    float HP = na, HP := coef0 *    whiten +
                         coef1 * nz(HP[1]) -
                         coef2 * nz(HP[2])

sups(series float Series,
     simple float Period) =>
    // John Ehlers' SuperSmoother Function
    float smooth = na
    if bar_index==0 or Period<2.0
        smooth := Series
    else
        var float afreq =  math.sqrt(2.0) * math.pi / Period
        var float alpha =  math.exp(-afreq)
        var float coef2 = -math.pow( alpha,   2)
        var float coef1 =  math.cos( afreq) * 2.0 * alpha
        var float coef0 =  1.0 - coef1 - coef2
        float     sma2  =  math.avg(Series, nz(Series[1], Series))
        smooth := coef0 *     sma2      +
                  coef1 * nz(smooth[1]) +
                  coef2 * nz(smooth[2])

roof(series float             Series=close,
     simple float      LowPassPeriod=  7.5,    // Lowpass period of roofing filter
     simple int       HighPassPeriod=   49,    // Highpass period of roofing filter
     simple bool   HighPassSelection= true) => // Optional parameter to select either a 2nd or 1st order highpass filter for the roofing filter
    // Custom Roofing Filter
    switch HighPassSelection
        true => sups(hp2nd(Series, HighPassPeriod), LowPassPeriod)
        =>      sups(hp1st(Series, HighPassPeriod), LowPassPeriod)


acs( series float     PassbandSeries,          // Passband series data on which a spectrum is to be generated from
     simple int   AutoCorrelationLag=    3,    // AutoCorrelation lag period
     simple float     PowerThreshold= 0.05,    // Threshold value to mitigate noisiness or sudden jumps in the dominant cycle
     simple float           Contrast=  3.0,    // Value to improve contrast of color and the resolution of the spectral measurements
     simple string   FourierFiltAlgo='ESS',    // Enables/disables smoothing of Fourier spectral components
     simple int    FourierFiltPeriod=   10) => // Fourier filter smoothing period
    // AutoCorrelation Spectrum Function
    var     int autoCorrelationLag_M1 = AutoCorrelationLag - 1
    var  array<float> aFourierFactors =  array.new<float>(50)
    var matrix<float> mSmoothingCoefs = matrix.new<float>(50, 3)
    if barstate.isfirst //⮟⮟⮟⮟⮟ Precalculate Coefficients and Fourier Factors ⮟⮟⮟⮟⮟
        for int p=6 to 49
            if FourierFiltAlgo == 'ESS'
                float afreq =  math.sqrt(2.0) * math.pi / math.min(p, FourierFiltPeriod)
                float alpha =  math.exp(-afreq)
                float coef2 = -math.pow( alpha,   2) 
                float coef1 =  math.cos( afreq) * 2.0 * alpha
                mSmoothingCoefs.set(p, 2,               coef2)
                mSmoothingCoefs.set(p, 1,       coef1        )
                mSmoothingCoefs.set(p, 0, 1.0 - coef1 - coef2)
            else
                float coef0 =  2.0 / (FourierFiltPeriod + 1)
                mSmoothingCoefs.set(p, 1, 1.0 - coef0)
                mSmoothingCoefs.set(p, 0,       coef0)
            aFourierFactors.set(p, 2.0 * math.pi / p)
    
    float passbandSeries2           =  math.pow(PassbandSeries, 2)
    array<float> aAutoCorrelationsR = array.new<float>(50, 0.0)
    for int p=0 to 49 //⮟⮟⮟⮟⮟ Calculate AutoCorrelations ⮟⮟⮟⮟⮟
        float Ex =0.0, float Ey =0.0, float Exy=0.0
        float Exx=0.0, float Eyy=0.0
        for int i=0 to autoCorrelationLag_M1
            float t = i + p
            float X = nz(PassbandSeries[i])
    		float Y = nz(PassbandSeries[t])
            Ex  += X
            Exy += X * Y
    	    Ey  +=     Y
            Exx += nz(passbandSeries2[i])
            Eyy += nz(passbandSeries2[t])
        float numerator   =  (AutoCorrelationLag * Exy - Ex * Ey)
        float denominator =  (AutoCorrelationLag * Exx - Ex * Ex) *
                             (AutoCorrelationLag * Eyy - Ey * Ey)
    	if denominator > 0.0
            aAutoCorrelationsR.set(p, numerator / math.sqrt(denominator))
    
    array<float> aSpectralComps = array.new<float>(50)
    for int p=6 to 49 //⮟⮟⮟⮟⮟ Decompose Fourier Components ⮟⮟⮟⮟⮟
        float realPart = 0.0
    	float imagPart = 0.0
        float angularFreqFactor = aFourierFactors.get(p)
        for int i=0 to 49
            float ACi = aAutoCorrelationsR.get(i)
    		realPart += math.cos(angularFreqFactor * i) * ACi
    		imagPart += math.sin(angularFreqFactor * i) * ACi
    	aSpectralComps.set(p, math.pow(realPart, 2) +
                              math.pow(imagPart, 2))
    
    array<float> aSmoothedFourierComps = array.new<float>(50)
    switch FourierFiltAlgo
        'ESS' =>
            for int p=6 to 49 //⮟⮟⮟⮟⮟ Fourier Components SuperSmoothed ⮟⮟⮟⮟⮟
                float currFourierMagnitude = aSpectralComps.get(p)
                float superSmoothCoef2    = mSmoothingCoefs.get(p, 2)
                float superSmoothCoef1    = mSmoothingCoefs.get(p, 1)
                float superSmoothCoef0    = mSmoothingCoefs.get(p, 0)
                float lastFourierSmoothed = currFourierMagnitude
                float prevFourierSmoothed = currFourierMagnitude
                if not na(aSmoothedFourierComps[1]) // Check for prior series array NOT being `na`(undefined)
                    lastFourierSmoothed := array.get(aSmoothedFourierComps[1], p) // Obtains last existing series array element
                    if not na(aSmoothedFourierComps[2]) // Check for prior series array NOT being `na`(undefined)
                        prevFourierSmoothed := array.get(aSmoothedFourierComps[2], p) // Obtains previous existing series array element
                    else
                        prevFourierSmoothed := lastFourierSmoothed // Substitution value when `na` is present
                aSmoothedFourierComps.set(p, superSmoothCoef0 * currFourierMagnitude +
                                             superSmoothCoef1 *  lastFourierSmoothed +
                                             superSmoothCoef2 *  prevFourierSmoothed) // SuperSmoother Coefficients on Fourier series arrays
        'EMA' =>
            for int p=6 to 49 //⮟⮟⮟⮟⮟ Fourier Components EMA Smoothed ⮟⮟⮟⮟⮟
                float currFourierMagnitude = aSpectralComps.get(p)
                float lastFourierSmoothed  = currFourierMagnitude
                if not na(aSmoothedFourierComps[1]) // Check for prior series array NOT being `na`(undefined)
                    lastFourierSmoothed := array.get(aSmoothedFourierComps[1], p) // Obtains last existing series array element
                aSmoothedFourierComps.set(p, mSmoothingCoefs.get(p, 0) * currFourierMagnitude +
                                             mSmoothingCoefs.get(p, 1) * lastFourierSmoothed) // Ehlers' original EMA on Fourier series arrays
        => // 'NONE'
            for int p=6 to 49
                aSmoothedFourierComps.set(p, aSpectralComps.get(p))
    
    float peakPower = aSmoothedFourierComps.get(6)
    for int p=7 to 49 //⮟⮟⮟⮟⮟ Find Peak Power Component ⮟⮟⮟⮟⮟
        float spectralComponent = aSmoothedFourierComps.get(p)
        if spectralComponent > peakPower
    	    peakPower := spectralComponent
    
    float dividend = 0.0
    float divisor  = 0.0
    for int p=6 to 49 //⮟⮟⮟⮟⮟ Determine Dominant Cycle Period ⮟⮟⮟⮟⮟
        float spectriNormalized = math.pow(aSmoothedFourierComps.get(p) / peakPower, Contrast)
        if spectriNormalized > PowerThreshold
            dividend += spectriNormalized * p
            divisor  += spectriNormalized
        aSpectralComps.set(p, spectriNormalized) // Reassign normalized spectral components for periodogram
    var float DOMINANT_CYCLE = 7
    if divisor > 0.25
        DOMINANT_CYCLE := math.max(7, dividend / divisor)
    
    [DOMINANT_CYCLE, aSpectralComps] // tuple returns


string grp0 = 'Source Options'
string selectSourceOrSine  = input.string('Source', 'Source Selection', group=grp0, inline='1', options=['Source','SineWave'])
float  source              = input.source(   hlcc4,                 '', group=grp0, inline='1', tooltip='This can be sourced to other generators/indicators')
float  sineWavePeriod      = input.float (    16.0,'  SineWave Period', group=grp0, minval=6.0, tooltip='Wavelength of the sinusoidal wave in bars')
string grp1 = 'Roofing Filter Options'
float  roofingFilterLP     = input.float (  7.5, 'Roofing Filter: Low-Pass Period', group=grp1,  minval=7.0,  step=0.5,   maxval=30.0)
int    roofingFilterHP     = input.int   (   49,         '       High-Pass Period', group=grp1,  minval=49)
bool   highpassSelection   = input.bool  ( true,    '     High-Pass Filter Choice', group=grp1, tooltip="true == Ehlers' 2nd Order High Pass\nfalse == Ehlers' 1st Order High Pass")
string grp2 = 'Spectral Controls'
int    autoCorrelationLag  = input.int   (    3,      'AutoCorrelation Lag', group=grp2, minval=2)
string fourierCoefsFilter  = input.string('ESS', 'Fourier Smoothing Method', group=grp2, inline='2', options=['ESS','EMA','NONE'], tooltip="ESS -> Ehlers' SuperSmoother\nEMA -> Basic EMA")
int    fourierSmoothPeriod = input.int   (    9,                         '', group=grp2, inline='2',  minval=7)
float  powerThreshold      = input.float ( 0.05,          'Power Threshold', group=grp2, minval=0.05,   step=0.05, tooltip='This affects the spectral values')
float  heatMapContrast     = input.float (  2.5,         'HeatMap Contrast', group=grp2, minval=1.0,    step=0.5,  tooltip='This affects both the coloring and the spectral values')
bool   heatMapColorScheme  = input.bool  ( true,    'Original Color Scheme', group=grp2)
string grp3 = 'Dominant Cycle Options'
string dominantCycleType   = input.string(   'Float',   'Dominant Cycle Type', group=grp3, options=['Float','Integer*'])
string dominantCycleForm   = input.string('Smoothed',   'Dominant Cycle Form', group=grp3, options=['Smoothed','Floor*','Round*'])
float  smoothDominantCycle = input.float (       7.0, 'Smooth Dominant Cycle', group=grp3,  minval=1.0)

float price                              = selectSourceOrSine=='Source' ? source * 10.0 : math.sin(bar_index * 6.2831853 / sineWavePeriod) * 21.0 + 28.0
float roofingFilter                      = roof(price, roofingFilterLP, roofingFilterHP, highpassSelection)
[dominantCycle, aSpectralPowerEstimates] =  acs(roofingFilter, autoCorrelationLag, powerThreshold, heatMapContrast, fourierCoefsFilter, fourierSmoothPeriod)

dominantCycle := if dominantCycleType=='Integer*'
    switch dominantCycleForm
        'Round*' => int(math.round(dominantCycle))
        =>          int(           dominantCycle)
else
    switch dominantCycleForm
        'Smoothed' => math.max(7.0, sups(dominantCycle, smoothDominantCycle))
        'Round*'   => math.round(dominantCycle)
        =>            math.floor(dominantCycle)

plot(selectSourceOrSine=='Source' ? na : price, 'SineWave', #FFFFFF)
plot(                            dominantCycle,   'DomCyc', #8000FF, 2)

//===== The Periodogram =====//
var hline06 = hline( 6, color=#00000000), var hline07 = hline( 7, color=#00000000), var hline08 = hline( 8, color=#00000000), var hline09 = hline( 9, color=#00000000), var hline10 = hline(10, color=#00000000)
var hline11 = hline(11, color=#00000000), var hline12 = hline(12, color=#00000000), var hline13 = hline(13, color=#00000000), var hline14 = hline(14, color=#00000000), var hline15 = hline(15, color=#00000000)
var hline16 = hline(16, color=#00000000), var hline17 = hline(17, color=#00000000), var hline18 = hline(18, color=#00000000), var hline19 = hline(19, color=#00000000), var hline20 = hline(20, color=#00000000)
var hline21 = hline(21, color=#00000000), var hline22 = hline(22, color=#00000000), var hline23 = hline(23, color=#00000000), var hline24 = hline(24, color=#00000000), var hline25 = hline(25, color=#00000000)
var hline26 = hline(26, color=#00000000), var hline27 = hline(27, color=#00000000), var hline28 = hline(28, color=#00000000), var hline29 = hline(29, color=#00000000), var hline30 = hline(30, color=#00000000)
var hline31 = hline(31, color=#00000000), var hline32 = hline(32, color=#00000000), var hline33 = hline(33, color=#00000000), var hline34 = hline(34, color=#00000000), var hline35 = hline(35, color=#00000000)
var hline36 = hline(36, color=#00000000), var hline37 = hline(37, color=#00000000), var hline38 = hline(38, color=#00000000), var hline39 = hline(39, color=#00000000), var hline40 = hline(40, color=#00000000)
var hline41 = hline(41, color=#00000000), var hline42 = hline(42, color=#00000000), var hline43 = hline(43, color=#00000000), var hline44 = hline(44, color=#00000000), var hline45 = hline(45, color=#00000000)
var hline46 = hline(46, color=#00000000), var hline47 = hline(47, color=#00000000), var hline48 = hline(48, color=#00000000), var hline49 = hline(49, color=#00000000), var hline50 = hline(50, color=#00000000)

fill(hline06, hline07, colorize(aSpectralPowerEstimates.get( 6), heatMapColorScheme))
fill(hline07, hline08, colorize(aSpectralPowerEstimates.get( 7), heatMapColorScheme))
fill(hline08, hline09, colorize(aSpectralPowerEstimates.get( 8), heatMapColorScheme))
fill(hline09, hline10, colorize(aSpectralPowerEstimates.get( 9), heatMapColorScheme))
fill(hline10, hline11, colorize(aSpectralPowerEstimates.get(10), heatMapColorScheme))
fill(hline11, hline12, colorize(aSpectralPowerEstimates.get(11), heatMapColorScheme))
fill(hline12, hline13, colorize(aSpectralPowerEstimates.get(12), heatMapColorScheme))
fill(hline13, hline14, colorize(aSpectralPowerEstimates.get(13), heatMapColorScheme))
fill(hline14, hline15, colorize(aSpectralPowerEstimates.get(14), heatMapColorScheme))
fill(hline15, hline16, colorize(aSpectralPowerEstimates.get(15), heatMapColorScheme))
fill(hline16, hline17, colorize(aSpectralPowerEstimates.get(16), heatMapColorScheme))
fill(hline17, hline18, colorize(aSpectralPowerEstimates.get(17), heatMapColorScheme))
fill(hline18, hline19, colorize(aSpectralPowerEstimates.get(18), heatMapColorScheme))
fill(hline19, hline20, colorize(aSpectralPowerEstimates.get(19), heatMapColorScheme))
fill(hline20, hline21, colorize(aSpectralPowerEstimates.get(20), heatMapColorScheme))
fill(hline21, hline22, colorize(aSpectralPowerEstimates.get(21), heatMapColorScheme))
fill(hline22, hline23, colorize(aSpectralPowerEstimates.get(22), heatMapColorScheme))
fill(hline23, hline24, colorize(aSpectralPowerEstimates.get(23), heatMapColorScheme))
fill(hline24, hline25, colorize(aSpectralPowerEstimates.get(24), heatMapColorScheme))
fill(hline25, hline26, colorize(aSpectralPowerEstimates.get(25), heatMapColorScheme))
fill(hline26, hline27, colorize(aSpectralPowerEstimates.get(26), heatMapColorScheme))
fill(hline27, hline28, colorize(aSpectralPowerEstimates.get(27), heatMapColorScheme))
fill(hline28, hline29, colorize(aSpectralPowerEstimates.get(28), heatMapColorScheme))
fill(hline29, hline30, colorize(aSpectralPowerEstimates.get(29), heatMapColorScheme))
fill(hline30, hline31, colorize(aSpectralPowerEstimates.get(30), heatMapColorScheme))
fill(hline31, hline32, colorize(aSpectralPowerEstimates.get(31), heatMapColorScheme))
fill(hline32, hline33, colorize(aSpectralPowerEstimates.get(32), heatMapColorScheme))
fill(hline33, hline34, colorize(aSpectralPowerEstimates.get(33), heatMapColorScheme))
fill(hline34, hline35, colorize(aSpectralPowerEstimates.get(34), heatMapColorScheme))
fill(hline35, hline36, colorize(aSpectralPowerEstimates.get(35), heatMapColorScheme))
fill(hline36, hline37, colorize(aSpectralPowerEstimates.get(36), heatMapColorScheme))
fill(hline37, hline38, colorize(aSpectralPowerEstimates.get(37), heatMapColorScheme))
fill(hline38, hline39, colorize(aSpectralPowerEstimates.get(38), heatMapColorScheme))
fill(hline39, hline40, colorize(aSpectralPowerEstimates.get(39), heatMapColorScheme))
fill(hline40, hline41, colorize(aSpectralPowerEstimates.get(40), heatMapColorScheme))
fill(hline41, hline42, colorize(aSpectralPowerEstimates.get(41), heatMapColorScheme))
fill(hline42, hline43, colorize(aSpectralPowerEstimates.get(42), heatMapColorScheme))
fill(hline43, hline44, colorize(aSpectralPowerEstimates.get(43), heatMapColorScheme))
fill(hline44, hline45, colorize(aSpectralPowerEstimates.get(44), heatMapColorScheme))
fill(hline45, hline46, colorize(aSpectralPowerEstimates.get(45), heatMapColorScheme))
fill(hline46, hline47, colorize(aSpectralPowerEstimates.get(46), heatMapColorScheme))
fill(hline47, hline48, colorize(aSpectralPowerEstimates.get(47), heatMapColorScheme))
fill(hline48, hline49, colorize(aSpectralPowerEstimates.get(48), heatMapColorScheme))
fill(hline49, hline50, colorize(aSpectralPowerEstimates.get(49), heatMapColorScheme))
````
