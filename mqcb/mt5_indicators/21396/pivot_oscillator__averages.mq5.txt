//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Pivot oscillator"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   8
#property indicator_label8  "Price"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrDimGray
#property indicator_width8  2
//
//---
//
enum enTimeFrames
  {
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3,             // Third higher time frame
   tf_cp4 = -4              // Fourth higher time frame
  };
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//
//---
//
input enTimeFrames       inpTimeFrame = tf_d1;         // Time frame
input int                inpMaPeriod  = 14;            // Average period
input enMaTypes          inpMaMethod  = ma_ema;        // Average method
input ENUM_APPLIED_PRICE inpMaPrice   = PRICE_TYPICAL; // Average price
input color              inpColorSup  = clrLimeGreen;  // Support lines color
input color              inpColorRes  = clrRed;        // Resistance lines color
input color              inpColorPiv  = clrGray;       // Pivot line color
input ENUM_LINE_STYLE    inpSaRStyle  = STYLE_DOT;     // Pivot, support and resistance lines style
//
//--- buffers declarations
//
double PBuffer[],S1Buffer[],R1Buffer[],S2Buffer[],R2Buffer[],S3Buffer[],R3Buffer[],Price[],count[];
//
//--- misc
//
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0)
string _avgNames[] = {"SMA","EMA","SMMA","LWMA"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,PBuffer ,INDICATOR_DATA); PlotIndexSetInteger(0,PLOT_LINE_COLOR,inpColorPiv);
   SetIndexBuffer(1,S1Buffer,INDICATOR_DATA); PlotIndexSetInteger(1,PLOT_LINE_COLOR,inpColorSup);
   SetIndexBuffer(2,R1Buffer,INDICATOR_DATA); PlotIndexSetInteger(2,PLOT_LINE_COLOR,inpColorRes);
   SetIndexBuffer(3,S2Buffer,INDICATOR_DATA); PlotIndexSetInteger(3,PLOT_LINE_COLOR,inpColorSup);
   SetIndexBuffer(4,R2Buffer,INDICATOR_DATA); PlotIndexSetInteger(4,PLOT_LINE_COLOR,inpColorRes);
   SetIndexBuffer(5,S3Buffer,INDICATOR_DATA); PlotIndexSetInteger(5,PLOT_LINE_COLOR,inpColorSup);
   SetIndexBuffer(6,R3Buffer,INDICATOR_DATA); PlotIndexSetInteger(6,PLOT_LINE_COLOR,inpColorRes);
   SetIndexBuffer(7,Price,INDICATOR_DATA);
   SetIndexBuffer(8,count,INDICATOR_CALCULATIONS);
   for (int i=0; i<7; i++)
   {
      PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);
      PlotIndexSetInteger(i,PLOT_LINE_STYLE,inpSaRStyle);
   }
   _indicatorTimeFrame = MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   _indicatorName      = getIndicatorName();
   if(_indicatorTimeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,_avgNames[inpMaMethod]+" pivot oscillator ("+timeFrameToString(_indicatorTimeFrame)+")");
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int _prevMark=0,_tfSeconds=PeriodSeconds(_indicatorTimeFrame),i=(int)MathMax(prev_calculated-1,0); 
   double P=0,R1=0,S1=0,R2=0,S2=0,R3=0,S3=0;
      if (_mtfHandle!=INVALID_HANDLE)
      {
         double result[1];
         if(BarsCalculated(_mtfHandle)<0)            return(prev_calculated);
         if(CopyBuffer(_mtfHandle,8,0,1,result)!= 1) return(prev_calculated);

         //
         //---
         //
      
         #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
         i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0));
      }     
      for(; i<rates_total && !_StopFlag; i++)
      {
         int _currMark=int(double(time[i]/_tfSeconds));
         if (_currMark!=_prevMark)
         {
            MqlRates _rates[]; 
                     int _ratesCopied = CopyRates(_Symbol,_indicatorTimeFrame,time[i],2,_rates);
                     double LastHigh  = (_ratesCopied==2) ? _rates[0].high  : 0;
                     double LastLow   = (_ratesCopied==2) ? _rates[0].low   : 0;
                     double LastClose = (_ratesCopied==2) ? _rates[0].close : 0;
               
             //
             //---
             //

             if (_ratesCopied==2)
             {               
                P  = (LastHigh+LastLow+LastClose)/3;
                R1 = (2*P)-LastLow;
                S1 = (2*P)-LastHigh;
                R2 = P+(LastHigh - LastLow);
                S2 = P-(LastHigh - LastLow);
                R3 = (2*P)+(LastHigh-(2*LastLow));
                S3 = (2*P)-((2* LastHigh)-LastLow); 
            }               
         }             

         //
         //---
         //
         
         double lower = S3;
         double range = R3-S3;
               if (range!=0)
               {
                  R3Buffer[i] =  1;
                  S3Buffer[i] = -1;
                  R1Buffer[i] = 2.0*((R1      -lower)/range-0.5);
                  S1Buffer[i] = 2.0*((S1      -lower)/range-0.5);
                  R2Buffer[i] = 2.0*((R2      -lower)/range-0.5);
                  S2Buffer[i] = 2.0*((S2      -lower)/range-0.5);
                  PBuffer[i]  = 2.0*((P       -lower)/range-0.5);
                  Price[i]    = 2.0*((iCustomMa(inpMaMethod,getPrice(inpMaPrice,open,close,high,low,i,rates_total),inpMaPeriod,i,rates_total)-lower)/range-0.5);
               }

     }
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars); int k;

   workSma[r][instanceNo+0]=price;
   double avg=price; for(k=1; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo+0];
   return(avg/k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<=1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight = period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//
//---
//
ENUM_TIMEFRAMES _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string          _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//
//---
//
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//
//---
//
ENUM_TIMEFRAMES timeFrameGet(int period)
  {
   int _shift=(period<0?MathAbs(period):0);
   if(_shift>0 || period==tf_cu) period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;

   return(_tfsPer[(int)MathMin(i+_shift,ArraySize(_tfsPer)-1)]);
  }
//
//---
//
string getIndicatorName()
  {
   string _path=MQL5InfoString(MQL5_PROGRAM_PATH); StringToLower(_path);
   string _partsA[];
   ushort _partsS=StringGetCharacter("\\",0);
   int    _partsN= StringSplit(_path,_partsS,_partsA);
   string name=_partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _partsA[n]!="indicators"; n--) name=_partsA[n]+"\\"+name;
   return(name);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
