//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "NonLag MA multi time frame version"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "NonLag MA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
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
   tf_cp3 = -3              // Third higher time frame
  };
input enTimeFrames       inpTimeFrame   = tf_cu;       // Time frame
input double             inpPeriod      = 27;          // Period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input bool               inpInterpolate = true;        // Interpolate in multi time frame mode?
//--- indicator buffers
double val[],valc[],count[];
//--- mtf handling
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES timeFrame;
#define _mtfCall iCustom(_Symbol,timeFrame,getIndicatorName(),0,inpPeriod,inpPrice)
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,count,INDICATOR_CALCULATIONS);
//---   
   timeFrame=MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   if(timeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" NonLag MA ("+(string)inpPeriod+")");
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
   if(timeFrame!=_Period)
     {
      double result[];
      if(BarsCalculated(_mtfHandle)<0)                     return(prev_calculated);
      if(!timeFrameCheck((ENUM_TIMEFRAMES)timeFrame,time)) return(prev_calculated);
      if(CopyBuffer(_mtfHandle,2,0,1,result)==-1)          return(prev_calculated);

      //
      //---
      //

      #define _mtfRatio PeriodSeconds((ENUM_TIMEFRAMES)timeFrame)/PeriodSeconds(_Period)
      int k,n,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-(int)result[0]*_mtfRatio-1,0)),_prevMark=0,_seconds=PeriodSeconds(timeFrame);
      for(; i<rates_total && !_StopFlag; i++)
        {
         int _currMark = int(time[i]/_seconds);
         if (_currMark!=_prevMark)
         {
            _prevMark = _currMark; 
            #define _mtfCopy(_buff,_buffNo) if(CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)==-1) break; _buff[i]=result[0]
                    _mtfCopy(val,0);
                    _mtfCopy(valc,1);
         }
         else
         {
            val[i]     = val[i-1];
            valc[i]    = valc[i-1];
         }            

         //
         //---
         //

         if (!inpInterpolate)  continue; 
            int _nextMark = (i<rates_total-1) ? int(time[i+1]/_seconds) : _prevMark+1; if (_nextMark == _prevMark) continue;
            for(n=1; (i-n)> 0 && time[i-n] >= (_prevMark)*_seconds; n++) continue;
            for(k=1; (i-k)>=0 && k<n; k++)
            {
               #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                       _mtfInterpolate(val);
            }
        }
      return(i);
     }
   //
   //---
   //
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      val[i]=iNonLagMa(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _length  0
#define _len     1
#define _weight  2
//
//---
//
double  nlmvalues[][3];
double  nlmprices[][1];
double  nlmalphas[][1];
//
//---
//
double iNonLagMa(double price,double length,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(nlmprices,0)!=bars) ArrayResize(nlmprices,bars);
   if(ArrayRange(nlmvalues,0)<instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
   nlmprices[r][instanceNo]=price;
   if(length<5 || r<3) return(nlmprices[r][instanceNo]);
//
//---
//
   if(nlmvalues[instanceNo][_length]!=length)
     {
      double Cycle = 4.0;
      double Coeff = 3.0*M_PI;
      int    Phase = (int)(length-1);

      nlmvalues[instanceNo][_length] =       length;
      nlmvalues[instanceNo][_len   ] = (int)(length*4) + Phase;
      nlmvalues[instanceNo][_weight] = 0;

      if(ArrayRange(nlmalphas,0)<(int)nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,(int)nlmvalues[instanceNo][_len]);
      for(int k=0; k<(int)nlmvalues[instanceNo][_len]; k++)
        {
         double t;
         if(k<=Phase-1)
               t = 1.0 * k/(Phase-1);
         else  t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0);
         double beta=MathCos(M_PI*t);
         double g=1.0/(Coeff*t+1); if(t<=0.5) g=1;

         nlmalphas[k][instanceNo]        = g * beta;
         nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
        }
     }
//
//---
//
   if(nlmvalues[instanceNo][_weight]>0)
     {
      double sum=0;
      for(int k=0; k<(int)nlmvalues[instanceNo][_len] && (r-k)>=0; k++) sum+=nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
      return( sum / nlmvalues[instanceNo][_weight]);
     }
   else return(0);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
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
   string _path=MQL5InfoString(MQL5_PROGRAM_PATH);
   string _partsA[];
   ushort _partsS=StringGetCharacter("\\",0);
   int _partsN = StringSplit(_path,_partsS,_partsA);
   string name = _partsA[_partsN-1]; for(int n=_partsN-2; n>=0 && _toLower(_partsA[n])!="indicators"; n--) name = _partsA[n]+"\\"+name;
   return(name);
  }
string _toLower(string _toConvert) { StringToLower(_toConvert); return(_toConvert); }
//
//---
//
bool timeFrameCheck(ENUM_TIMEFRAMES _timeFrame,const datetime &time[])
  {
   static bool warned=false;
   if(time[0]<SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE))
     {
      datetime startTime,testTime[];
      if(SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,startTime))
      if(startTime>0)                       { CopyTime(_Symbol,_timeFrame,time[0],1,testTime); SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE,startTime); }
      if(startTime<=0 || startTime>time[0]) { Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+"\nMissing data for "+timeFrameToString(_timeFrame)+" time frame\nRe-trying on next tick"); warned=true; return(false); }
     }
   if(warned) { Comment(""); warned=false; }
   return(true);
  }
//+------------------------------------------------------------------+
