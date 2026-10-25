//+------------------------------------------------------------------+
//|                                          GARCH_vol_threshold.mq5 |
//|                                  Copyright 2025, Serhad Yildirim |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Serhad Yildirim"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "GARCH_Vol"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCadetBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Threshold"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//--- indicator buffers
double VolBuf[];
double ThreshBuf[];

//--- rolling-window buffer and params
double winVol[];
int    bufPos = 0;
bool   bufFull = false;
int    VolLookback = 0;
double historyDays;

//--- GARCH(1,1) and Welford state (no statics)
double sigma_prev = 0.0;
double meanVol     = 0.0;
double M2Vol       = 0.0;
int    countVol    = 0;

//--- input GARCH(1,1) params
input double InpGamma         = 9.3493e-07;   // Gamma: constant term (unconditional variance)
input double InpAlpha1        = 0.065834;     // Alpha: ARCH coefficient (reaction to last shock²)
input double beta1            = 0.921607;     // Beta: GARCH coefficient (persistence of past variance)
input int    InpWindowBars    = 1000;         // Bar window: How many bars to include in rolling mean/std
input double InpK             = 1.0;          // Threshold: meanVol + StdMultiplier * stdVol

//+------------------------------------------------------------------+
//| init function                                                    |
//+------------------------------------------------------------------+
int OnInit()
   {
//--- calculate lookback window from timeframe
    historyDays = GetHistoryDays(_Period);
    double tfMinutes = double(PeriodSeconds(_Period)) / 60.0;
    VolLookback      = int(MathCeil(historyDays * (1440.0/tfMinutes)));
    VolLookback      = MathMin(VolLookback, Bars(_Symbol,_Period)-3);
    VolLookback      = MathMax(VolLookback, 10);

//--- ensure sufficient lookback
    if(VolLookback < 2)
       {
        Print("VolLookback too small: ", VolLookback);
        return(INIT_PARAMETERS_INCORRECT);
       }

//--- validate GARCH parameters
    if(InpGamma <= 0 || InpAlpha1 < 0 || beta1 < 0 || (InpAlpha1 + beta1) >= 1.0)
       {
        Print("Invalid GARCH params: require α₀>0, α₁≥0, β₁≥0, α₁+β₁<1");
        return(INIT_PARAMETERS_INCORRECT);
       }

//--- initialize rolling-window buffers
    ArrayResize(winVol, VolLookback);
    ArrayInitialize(winVol, 0.0);
    bufPos   = 0;
    bufFull  = false;
    countVol = 0;
    meanVol  = 0.0;
    M2Vol    = 0.0;

//--- set initial GARCH vol at unconditional level
    sigma_prev = MathSqrt(InpGamma / (1.0 - InpAlpha1 - beta1));

// setup indicator buffers and plotting
    SetIndexBuffer(0, VolBuf,   INDICATOR_DATA);
    SetIndexBuffer(1, ThreshBuf,INDICATOR_DATA);
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
    ArrayInitialize(VolBuf,   EMPTY_VALUE);
    ArrayInitialize(ThreshBuf,EMPTY_VALUE);

// only draw once warm-up complete
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, VolLookback);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, VolLookback);

    return(INIT_SUCCEEDED);
   }

//+------------------------------------------------------------------+
//| calculate function                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
   {
    int start = MathMax(3, VolLookback);
    int begin = prev_calculated > 0 ? prev_calculated : start;

    for(int i = begin; i < rates_total; i++)
       {
        //--- compute log-return
        double Z_t1 = MathLog(close[i-1] / close[i-2]);

        //--- GARCH(1,1) variance update
        double var_i   = InpGamma + InpAlpha1 * Z_t1 * Z_t1 + beta1 * sigma_prev * sigma_prev;
        double sigma_i = MathSqrt(var_i);

        VolBuf[i]    = sigma_i;
        sigma_prev   = sigma_i;

        //--- Welford sliding-window update
        if(countVol < VolLookback)
           {
            //--- initial fill
            countVol++;
            double delta = sigma_i - meanVol;
            meanVol += delta / countVol;
            M2Vol   += delta * (sigma_i - meanVol);
            winVol[bufPos] = sigma_i;
            if(countVol == VolLookback)
                bufFull = true;
           }
        else
           {
            //--- remove oldest sample
            double old = winVol[bufPos];
            double deltaR = old - meanVol;
            meanVol -= deltaR / VolLookback;
            M2Vol   -= deltaR * (old - meanVol);

            //--- add newest sample
            double deltaA = sigma_i - meanVol;
            meanVol += deltaA / VolLookback;
            M2Vol   += deltaA * (sigma_i - meanVol);
            winVol[bufPos] = sigma_i;
           }

        //--- advance circular index
        bufPos = (bufPos + 1) % VolLookback;

        //--- threshold computation once enough data
        if(countVol >= 2)
           {
            double varV = M2Vol / (countVol - 1);
            varV = MathMax(varV, 0.0);   // guard negative drift
            double sdV  = MathSqrt(varV);
            ThreshBuf[i] = meanVol + InpK * sdV;
           }
        else
           {
            ThreshBuf[i] = EMPTY_VALUE;
           }
       }
    return(rates_total);
   }

//+------------------------------------------------------------------+
//| history length in days for timeframe                             |
//+------------------------------------------------------------------+
double GetHistoryDays(const ENUM_TIMEFRAMES period)
   {
    switch(period)
       {
        case PERIOD_M1:
        case PERIOD_M5:
        case PERIOD_M15:
            return(1.0);
        case PERIOD_M30:
            return(7.0);
        case PERIOD_H1:
        case PERIOD_H4:
            return(14.0);
        case PERIOD_D1:
            return(252.0);
        case PERIOD_W1:
            return(252.0*2);
        case PERIOD_MN1:
            return(252.0*5);
        default:
            return(252.0);
       }
   }
//+------------------------------------------------------------------+
