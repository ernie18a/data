//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Fibo pivots"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//--- input parameters
input enTimeFrames  inpTimeFrame = tf_d1;           // Time frame
input string        inpLevels    = "0.382;0.618;1"; // Levels
input color         inpPivot     = clrGray;         // Pivot color
input color         inpFiboUp    = clrDodgerBlue;   // Upper fibo level
input color         inpFiboDown  = clrSandyBrown;   // Lower fibo level

double _levels[]; int _levelsSize=0; ENUM_TIMEFRAMES timeFrame;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   timeFrame=MathMax(timeFrameGet((int)inpTimeFrame),_Period);
   ushort _sep=StringGetCharacter(";",0);
   string _levelsStrings[];
   _levelsSize=StringSplit(inpLevels,_sep,_levelsStrings);
   ArrayResize(_levels,_levelsSize);
   for(int i=0; i<_levelsSize; i++) _levels[i]=StringToDouble(_levelsStrings[i]);
   if (_levelsSize<=0) return(INIT_FAILED);
                       return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { ObjectsDeleteAll(0,"fibo pivots:");return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int _prevMark=0,_seconds=PeriodSeconds(timeFrame);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _currMark= int(time[i]/_seconds);
      if(_currMark!=_prevMark)
        {
         _prevMark=_currMark;
         MqlRates _rates[2];
         int _copiedRates=CopyRates(_Symbol,timeFrame,time[i],2,_rates);
         if(_copiedRates==2)
           {
            double pivot = (_rates[0].high+_rates[0].low+_rates[1].open)/3;
            double range = (_rates[0].high-_rates[0].low);
            string _namep= "fibo pivots:"+(string)_rates[0].time+":p";
            ObjectDelete(0,_namep);
            ObjectCreate(0,_namep,OBJ_TREND,0,_rates[1].time,pivot,_rates[1].time+_seconds,pivot);
            ObjectSetInteger(0,_namep,OBJPROP_COLOR,inpPivot);
            ObjectSetInteger(0,_namep,OBJPROP_WIDTH,1);
            ObjectSetInteger(0,_namep,OBJPROP_STYLE,STYLE_DOT);

            //
            //---
            //

            for(int k=0; k<_levelsSize; k++)
              {
               string _nameu = "fibo pivots:"+(string)_rates[0].time+":u"+(string)k;
               string _named = "fibo pivots:"+(string)_rates[0].time+":d"+(string)k;
               ObjectDelete(0,_nameu);
               ObjectDelete(0,_named);
               ObjectCreate(0,_nameu,OBJ_TREND,0,_rates[1].time,pivot+range*_levels[k],_rates[1].time+_seconds,pivot+range*_levels[k]);
               ObjectSetInteger(0,_nameu,OBJPROP_COLOR,inpFiboUp);
               ObjectSetInteger(0,_nameu,OBJPROP_WIDTH,1);
               ObjectCreate(0,_named,OBJ_TREND,0,_rates[1].time,pivot-range*_levels[k],_rates[1].time+_seconds,pivot-range*_levels[k]);
               ObjectSetInteger(0,_named,OBJPROP_COLOR,inpFiboDown);
               ObjectSetInteger(0,_named,OBJPROP_WIDTH,1);
              }
           }
        }
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
