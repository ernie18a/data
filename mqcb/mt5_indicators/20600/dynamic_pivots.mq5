//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Dynamic pivots"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   7
#property indicator_label1  "Pivot high 3"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_label2  "Pivot high 2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_label3  "Pivot high 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_label4  "Pivot"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDimGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Pivot low 1"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrRed
#property indicator_label6  "Pivot low 2"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_label7  "Pivot low 3"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
//--- input parameters
input double PivotLevel1            = 0.38;  // Pivot level 1
input double PivotLevel2            = 0.61;  // Pivot level 2
input double PivotLevel3            = 1.00;  // Pivot level 3
input bool   AlternativeCalculation = true;  // Use alternative calculation?
//--- indicator buffers
double ul3[],ul2[],ul1[],mid[],dl1[],dl2[],dl3[],counter[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator works only for time frames less than daily
   if(_Period>=PERIOD_D1)
     {
      Alert("Indicator will work only on time frames less than daily");
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,ul3,INDICATOR_DATA);
   SetIndexBuffer(1,ul2,INDICATOR_DATA);
   SetIndexBuffer(2,ul1,INDICATOR_DATA);
   SetIndexBuffer(3,mid,INDICATOR_DATA);
   SetIndexBuffer(4,dl1,INDICATOR_DATA);
   SetIndexBuffer(5,dl2,INDICATOR_DATA);
   SetIndexBuffer(6,dl3,INDICATOR_DATA);
   SetIndexBuffer(7,counter,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Dynamic pivots");
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
   int _divisor=PeriodSeconds(PERIOD_D1);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      counter[i] = (i>0) ? (time[i]/_divisor)==(time[i-1]/_divisor) ? counter[i-1] : i : 0;
      int _start = (int)counter[i];
      double dayHigh = high[ArrayMaximum(high,_start,i-_start+1)];
      double dayLow  = low [ArrayMinimum(low ,_start,i-_start+1)];
      double range   = dayHigh-dayLow;

      //
      //
      //
      //
      //

      mid[i]=(dayHigh+dayLow)/2.0;
      if(AlternativeCalculation)
        {
         ul3[i] = (dayHigh+mid[i])/2.0;
         dl3[i] = (dayLow +mid[i])/2.0;
         if(PivotLevel1>0) if(PivotLevel1>0.5) { dl1[i] = EMPTY_VALUE; ul1[i] = dayLow+range*PivotLevel1; } else { ul1[i] = EMPTY_VALUE; dl1[i] = dayLow+range*PivotLevel1; }
         if(PivotLevel2>0) if(PivotLevel2>0.5) { dl2[i] = EMPTY_VALUE; ul2[i] = dayLow+range*PivotLevel2; } else { ul1[i] = EMPTY_VALUE; dl2[i] = dayLow+range*PivotLevel2; }
        }
      else
        {
         if(PivotLevel1>0) { ul1[i] = mid[i]+range*PivotLevel1; dl1[i] = mid[i]-range*PivotLevel1; }
         if(PivotLevel2>0) { ul2[i] = mid[i]+range*PivotLevel2; dl2[i] = mid[i]-range*PivotLevel2; }
         if(PivotLevel3>0) { ul3[i] = mid[i]+range*PivotLevel3; dl3[i] = mid[i]-range*PivotLevel3; }
        }
     }
   return (i);
  }
//+------------------------------------------------------------------+
