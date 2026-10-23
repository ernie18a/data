//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "RSX Range expansion index (REI)"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Range expansion index"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int inpReiPeriod = 14; // REI period
//--- buffers declarations
double val[],valc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Range expansion index (REI) ("+(string)inpReiPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = (iRsx(high[i],inpReiPeriod,i,0)+iRsx(low[i],inpReiPeriod,i,1))-100;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsxInstances      2
#define _rsxInstancesSize 13
#define _rsxRingSize       5
double workRsi[_rsxRingSize][_rsxInstances*_rsxInstancesSize];
//
//---
//
double iRsx(double price,double period,int i, int instanceNo=0)
  {
   int _indP = (int)MathMod(i-1,_rsxRingSize);
   int _indC = (int)MathMod(i  ,_rsxRingSize);
   int _inst = instanceNo*_rsxInstancesSize;
   
      if(i<period) { for(int k=1; k<_rsxInstancesSize; k++) workRsi[_indC][_inst+k]=0; return(50); }
   
      workRsi[_indC][_inst]=price;
      double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
      //
      //---
      //
      double mom = workRsi[_indC][_inst]-workRsi[_indP][_inst];
      double moa = MathAbs(mom);
      for(int k=0; k<3; k++)
      {
         int kk=_inst+k*2;
         workRsi[_indC][kk+1] = Kg*mom                  + Hg*workRsi[_indP][kk+1];
         workRsi[_indC][kk+2] = Kg*workRsi[_indC][kk+1] + Hg*workRsi[_indP][kk+2]; mom = 1.5*workRsi[_indC][kk+1] - 0.5 * workRsi[_indC][kk+2];
         workRsi[_indC][kk+7] = Kg*moa                  + Hg*workRsi[_indP][kk+7];
         workRsi[_indC][kk+8] = Kg*workRsi[_indC][kk+7] + Hg*workRsi[_indP][kk+8]; moa = 1.5*workRsi[_indC][kk+7] - 0.5 * workRsi[_indC][kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
  }
//+------------------------------------------------------------------+
