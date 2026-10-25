//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "RSX Range expansion index (REI)"
#property description "With confidence bands"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_style3  STYLE_DOT
#property indicator_label4  "REI"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrCrimson,clrForestGreen
#property indicator_width4  2
//--- input parameters
enum enColorMode
{
   col_onZero, // Change color on middle line cross
   col_onOuter // Change color on outer levels cross
};
input double      inpPeriod               = 32;         // REI period
input double      inpConfidenceLevel      = 95.0;       // Confidence level
input int         inpConfidenceBandsShift = 2;          // Confidence level shift
input enColorMode inpColorMode            = col_onZero; // Change color mode 
//--- indicator buffers
double val[],valc[],flup[],flmi[],fldn[];
double ConfidenceZ,ConfidenceLevel; int ConfidenceBandsShift;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,flup,INDICATOR_DATA);
   SetIndexBuffer(1,flmi,INDICATOR_DATA);
   SetIndexBuffer(2,fldn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
         ConfidenceLevel = MathMax(MathMin(inpConfidenceLevel,99.9999999999),0.0000000001);
         ConfidenceBandsShift=MathMax(inpConfidenceBandsShift,1);
         ConfidenceZ = NormalCDFInverse((ConfidenceLevel+(100-ConfidenceLevel)/2.0)/100.0);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"RSX Range expansion index ("+(string)inpPeriod+" with "+(string)inpConfidenceLevel+" confidence bands)");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
         val[i] = (iRsx(high[i],inpPeriod,i,0)+iRsx(low[i],inpPeriod,i,1))-100;
         double va = (i-ConfidenceBandsShift>=0) ? (val[i-ConfidenceBandsShift]+100.0)/200.0 : 0;
         double me = ConfidenceZ*MathSqrt(va*(1.0-va)/inpPeriod)*100.0;
            flup[i] = (i-ConfidenceBandsShift>=0) ? val[i-ConfidenceBandsShift]+me : val[i];
            fldn[i] = (i-ConfidenceBandsShift>=0) ? val[i-ConfidenceBandsShift]-me : val[i];
            flmi[i] = (flup[i]+fldn[i])/2.0;
         switch (inpColorMode)
         {
            case col_onOuter : valc[i] = (val[i]>flup[i]) ? 2 :(val[i]<fldn[i]) ? 1 : 0; break;
            case col_onZero  : valc[i] = (val[i]>flmi[i]) ? 2 :(val[i]<flmi[i]) ? 1 : (i>0) ? valc[i-1]: 0; break;
         }            
     }
   return(rates_total);
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
//
//---
//  
double _cbc[] = {2.515517, 0.802853, 0.010328};
double _cbd[] = {1.432788, 0.189269, 0.001308};
double RationalApproximation(double t)
{
    return (t - (( _cbc[2]*t + _cbc[1])*t + _cbc[0]) / 
                (((_cbd[2]*t + _cbd[1])*t + _cbd[0])*t + 1.0));
}
double NormalCDFInverse(double p)
{
    if (p <= 0.0 || p >= 1.0) return(0);
    if (p < 0.5)
           return (-RationalApproximation(MathSqrt(-2.0*MathLog(p))));
    else   return ( RationalApproximation(MathSqrt(-2.0*MathLog(1.0-p))));
} 
//+------------------------------------------------------------------+
