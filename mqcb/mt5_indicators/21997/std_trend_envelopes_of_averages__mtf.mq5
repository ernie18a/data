//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "STD Trend envelopes of averages - mtf"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Trend envelope up trend line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Trend envelope down trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  2
#property indicator_label3  "Trend envelope up trend start"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_width3  2
#property indicator_label4  "Trend envelope down trend start"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrCrimson
#property indicator_width4  2

//
//--- input parameters
//
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
//
//---
//
input enTimeFrames inpTimeFrame = tf_cu;   // Time frame
input int          inpDevPeriod = 14;      // Deviations period
input double       inpDeviation = 1.5;     // Deviations multilication factor
input int          inpSmtPeriod = 14;      // Smoothing period (<=1 for no smoothing)
input enMaTypes    inpMaMethod  = ma_sma;  // Smoothing method
input bool         inpInterpolate = true;  // Interpolate in multi time frame mode?


//
//--- indicator buffers
//

double lineup[],linedn[],arrowup[],arrowdn[],count[];

//
//--- custom structures
//

struct sTrendEnvelope
{
   double upline;
   double downline;
   int    trend;
   bool   trendChange;
};
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,inpDevPeriod,inpDeviation,inpSmtPeriod,inpMaMethod)

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,lineup,INDICATOR_DATA);
   SetIndexBuffer(1,linedn,INDICATOR_DATA);
   SetIndexBuffer(2,arrowup,INDICATOR_DATA); PlotIndexGetInteger(2,PLOT_ARROW,159);
   SetIndexBuffer(3,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(3,PLOT_ARROW,159);
   SetIndexBuffer(4,count,INDICATOR_CALCULATIONS);   
//---
   _indicatorTimeFrame = MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   _indicatorName      = getIndicatorName();
   if(_indicatorTimeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_indicatorTimeFrame)+" STD trend envelopes ("+(string)inpDevPeriod+")");
   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   if(_indicatorTimeFrame!=_Period)
     {
      double result[];
      if(BarsCalculated(_mtfHandle)<0)              return(prev_calculated);
      if(!timeFrameCheck(_indicatorTimeFrame,time)) return(prev_calculated);
      if(CopyBuffer(_mtfHandle,4,0,1,result)==-1)   return(prev_calculated);

      //
      //---
      //
      
      #define _mtfRatio (double)PeriodSeconds((ENUM_TIMEFRAMES)_indicatorTimeFrame)/PeriodSeconds(_Period)
      int k,n,i=MathMin(MathMax(prev_calculated-1,0),MathMax(rates_total-int(result[0]*_mtfRatio)-1,0)),_prevMark=0,_seconds=PeriodSeconds(_indicatorTimeFrame);
      for(; i<rates_total && !_StopFlag; i++)
        {
         int _currMark= int(time[i]/_seconds);
         if (_currMark!=_prevMark)
            {
               _prevMark=_currMark;
               #define _mtfCopy(_buff,_buffNo) if(CopyBuffer(_mtfHandle,_buffNo,time[i],1,result)<=0) break; _buff[i]=result[0]
                       _mtfCopy(lineup ,0);
                       _mtfCopy(linedn ,1);
                       _mtfCopy(arrowup,2);
                       _mtfCopy(arrowdn,3);
            }
            else
            {
               lineup[i]  = lineup[i-1];
               linedn[i]  = linedn[i-1];
               arrowdn[i] = EMPTY_VALUE;
               arrowup[i] = EMPTY_VALUE;
            }

            //
            //---
            //

            if(!inpInterpolate) continue;
            int _nextMark=(i<rates_total-1) ? int(time[i+1]/_seconds) : _prevMark+1; if(_nextMark==_prevMark) continue;
            for(n=1; (i-n)> 0 && time[i-n] >= (_prevMark)*_seconds; n++) continue;
            for(k=1; (i-k)>=0 && k<n; k++)
            {
               #define _mtfInterpolate(_buff) _buff[i-k]=_buff[i]+(_buff[i-n]-_buff[i])*k/n
                       if (lineup[i]!=EMPTY_VALUE && lineup[i-n]!=EMPTY_VALUE) _mtfInterpolate(lineup);
                       if (linedn[i]!=EMPTY_VALUE && linedn[i-n]!=EMPTY_VALUE) _mtfInterpolate(linedn);
            }
         }
         return(i);
     }

   
   //
   //---
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _dev = iDeviation(close[i],inpDevPeriod,i,rates_total);
      double _high = iCustomMa(inpMaMethod,high[i],inpSmtPeriod,i,rates_total,0);
      double _low  = iCustomMa(inpMaMethod,low[i] ,inpSmtPeriod,i,rates_total,1);
      sTrendEnvelope _result = iTrendEnvelope(_high,_low,close[i],_dev*inpDeviation,i,rates_total);
         lineup[i]  = _result.upline;
         linedn[i]  = _result.downline;
         arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
         arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
   }          
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return(rates_total);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
double workDev[];
//
//---
//
double iDeviation(double value,int length,int i,int bars,bool isSample=false)
  {
   if(ArraySize(workDev)!=bars) ArrayResize(workDev,bars);  workDev[i]=value;
   double sumx=0,sumxx=0; for(int k=0; k<length && (i-k)>=0; sumx+=workDev[i-k],sumxx+=workDev[i-k]*workDev[i-k],k++) {}
   return(MathSqrt((sumxx-sumx*sumx/length)/MathMax(length-isSample,1)));
  }
//
//---
//
#define _maInstances 2
#define _maWorkBufferx1 _maInstances
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
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
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

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//
//---
//
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1 
#define _teTrend 2

//
//---
//

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars); instanceNo*=_trendEnvelopesInstancesSize;
   
   //
   //---
   //
   
   workTrendEnvelopes[i][instanceNo+_teSmax]  = valueh+deviation;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = valuel-deviation;
	workTrendEnvelopes[i][instanceNo+_teTrend] = (i>0) ? (value>workTrendEnvelopes[i-1][instanceNo+_teSmax]) ? 1 : (value<workTrendEnvelopes[i-1][instanceNo+_teSmin]) ? -1 : workTrendEnvelopes[i-1][instanceNo+_teTrend] : 0;
   	if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]>0 && workTrendEnvelopes[i][instanceNo+_teSmin]<workTrendEnvelopes[i-1][instanceNo+_teSmin]) workTrendEnvelopes[i][instanceNo+_teSmin] = workTrendEnvelopes[i-1][instanceNo+_teSmin];
	   if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]<0 && workTrendEnvelopes[i][instanceNo+_teSmax]>workTrendEnvelopes[i-1][instanceNo+_teSmax]) workTrendEnvelopes[i][instanceNo+_teSmax] = workTrendEnvelopes[i-1][instanceNo+_teSmax];
   
      //
      //---
      //
      
      sTrendEnvelope _result;
	                  _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
                     _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
                     _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? workTrendEnvelopes[i][instanceNo+_teSmin] : EMPTY_VALUE;
                     _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? workTrendEnvelopes[i][instanceNo+_teSmax] : EMPTY_VALUE;
      return(_result);                  
};
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
bool timeFrameCheck(ENUM_TIMEFRAMES _timeFrame,const datetime &time[])
  {
   if(time[0]<SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE))
     {
      datetime startTime,testTime[];
      if(SeriesInfoInteger(_Symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,startTime))
      if(startTime>0)                       { CopyTime(_Symbol,_timeFrame,time[0],1,testTime); SeriesInfoInteger(_Symbol,_timeFrame,SERIES_FIRSTDATE,startTime); }
      if(startTime<=0 || startTime>time[0]) { Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+"\nMissing data for "+timeFrameToString(_timeFrame)+" time frame\nRe-trying on next tick"); return(false); }
     }
   string _comment = ChartGetString(0,CHART_COMMENT);     
   string _shortName = MQL5InfoString(MQL5_PROGRAM_NAME);
   if (StringFind(_comment,_shortName,0)>=0) Comment("");
   return(true);
  } 
//+------------------------------------------------------------------+
