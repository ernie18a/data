//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend trigger factor"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend trigger factor levels"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  0
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrOrangeRed
#property indicator_width3  2
//
//---
//
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
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
input enTimeFrames inpTimeFrame     = tf_cu;         // Time frame
input int          inpPeriod        = 15;            // Period
input int          inpT3Period      = 5;             // T3 period
input double       inpT3Hot         = 0.7;           // T3 hot 
input enT3Type     inpT3Type        = t3_fulksmat;   // T3 type
input double       inpLevels        = 100;           // Levels at +- (nnn)
input bool         inpInterpolate   = true;          // Interpolate in multi time frame mode?

double val[],valc[],lev[],fup[],fdn[],count[];
int     _mtfHandle=INVALID_HANDLE; ENUM_TIMEFRAMES _indicatorTimeFrame; string _indicatorName;
#define _mtfCall iCustom(_Symbol,_indicatorTimeFrame,_indicatorName,0,inpPeriod,inpT3Period,inpT3Hot,inpT3Type,inpLevels)
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   SetIndexBuffer(0,fup,INDICATOR_DATA);     
   SetIndexBuffer(1,fdn,INDICATOR_DATA);
   SetIndexBuffer(2,lev,INDICATOR_DATA); 
   SetIndexBuffer(3,val,INDICATOR_DATA); 
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,count,INDICATOR_CALCULATIONS);
//
//---
//
   _indicatorTimeFrame = MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   _indicatorName      = getIndicatorName();
   if(_indicatorTimeFrame!=_Period)
     {
      _mtfHandle = _mtfCall; if(_mtfHandle==INVALID_HANDLE) return(INIT_FAILED);
     }
     IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(_indicatorTimeFrame)+" Trend trigger factor ("+(string)inpPeriod+","+(string)inpT3Period+")");
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { return; }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(_indicatorTimeFrame!=_Period)
     {
      double result[];
      if(BarsCalculated(_mtfHandle)<0)              return(prev_calculated);
      if(!timeFrameCheck(_indicatorTimeFrame,time)) return(prev_calculated);
      if(CopyBuffer(_mtfHandle,5,0,1,result)==-1)   return(prev_calculated);

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
                       _mtfCopy(fup ,0);
                       _mtfCopy(fdn ,1);
                       _mtfCopy(lev ,2);
                       _mtfCopy(val ,3);
                       _mtfCopy(valc,4);
            }
            else
            {
               val[i]  = val[i-1];
               valc[i] = valc[i-1];
               fup[i]  = fup[i-1];  
               fdn[i]  = fdn[i-1];
               lev[i]  = lev[i-1];
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
                       _mtfInterpolate(val);
                        fup[i-k] =  val[i-k];
                        fdn[i-k] = (val[i]>0) ? MathMin(val[i-k],inpLevels) : MathMax(val[i-k],-inpLevels);
            }
         }
         return(i);
     }

   //
   //---
   //
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         int _start  = MathMax(i-inpPeriod+1,0);
         int _starto = MathMax(i-inpPeriod-inpPeriod+1,0);
         double HighestHighRecent = high[ArrayMaximum(high,_start ,inpPeriod)];
         double HighestHighOlder  = high[ArrayMaximum(high,_starto,inpPeriod)];
         double LowestLowRecent   = low [ArrayMinimum(low ,_start ,inpPeriod)];
         double LowestLowOlder    = low [ArrayMinimum(low ,_starto,inpPeriod)];
         double BuyPower  = HighestHighRecent - LowestLowOlder;
         double SellPower = HighestHighOlder  - LowestLowRecent;
         double ttf = (BuyPower+SellPower!=0) ? 100*(BuyPower-SellPower)/(0.5*(BuyPower+SellPower)) : 0;
         val[i]  = iT3(ttf,inpT3Period,inpT3Hot,inpT3Type==t3_tillson,i,rates_total);     
         valc[i] = (val[i]>inpLevels) ? 1 : (val[i]<-inpLevels) ? 2 : 0;
         lev[i]  = (val[i]>0) ? inpLevels : (val[i]<0) ? -inpLevels : 0;
         fup[i]  =  val[i];
         fdn[i]  = (val[i]>0) ? MathMin(val[i],inpLevels) : MathMax(val[i],-inpLevels);
     }
   count[rates_total-1]=MathMax(rates_total-prev_calculated+1,1);
   return(i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances     1
#define _t3InstancesSize 6
double workT3[][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//
//
//
//

double iT3(double price,double period,double hot,bool original,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workT3,0)!=bars) ArrayResize(workT3,bars);
   if(ArrayRange(workT3Coeffs,0)<(instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);
   if(workT3Coeffs[instanceNo][_period]!=period)
     {
      workT3Coeffs[instanceNo][_period]=period;
      workT3Coeffs[instanceNo][_c1] = -hot*hot*hot;
      workT3Coeffs[instanceNo][_c2] = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c3] = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c4] = 1+3*hot+hot*hot*hot+3*hot*hot;
      if(original)
         workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
      else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
     }

//
//
//
//
//

   int buffer=instanceNo*_t3InstancesSize; for(int k=0; k<6; k++) workT3[r][k+buffer]=(r>0) ? workT3[r-1][k+buffer]: price;
   if(r>0 && period>1)
     {
      workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
      workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
      workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
      workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
      workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
      workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
     }
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] +
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer]+
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer]+
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
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
