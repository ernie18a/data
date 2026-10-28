//+------------------------------------------------------------------+
//|                                                         DXMA.mq5 |
//|                                              Copyright 2010, kur |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "2010, kurl"
#property link        "https://forge.mql5.io"
#property description "DMI expanded MA"//s
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  SkyBlue
#property indicator_width1  1
#property indicator_label1  "DXMAs"
#property indicator_applied_price PRICE_CLOSE
//--- input parameters
input int   MAperiod=20;
double   D[];
double   C[];
double P[],M[];
int   hADX;//handle
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   string label="DXMA("+string(MAperiod)+")";

   SetIndexBuffer(0,D,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MAperiod);
   PlotIndexSetString(0,PLOT_LABEL,label);

   SetIndexBuffer(1,P,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,C,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,M,INDICATOR_CALCULATIONS);

   IndicatorSetString(INDICATOR_SHORTNAME,label);

   hADX=iADX(_Symbol,_Period,MAperiod);
  }
//+------------------------------------------------------------------+
//| DMI expanded MA
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   double hi[],lo[];
   ArrayResize(hi,MAperiod);ArrayResize(lo,MAperiod);
   int n,i,limit;
   if(prev_calculated==0)n=rates_total;
   else{n=rates_total-prev_calculated+1;}
   if(CopyBuffer(hADX,1,0,n,P)<=0){return(0);}
   if(CopyBuffer(hADX,2,0,n,M)<=0){return(0);}
   if(prev_calculated==0){limit=MAperiod;}
   else{limit=prev_calculated-1;}
   for(i=limit;i<rates_total;i++)
     {
      int s=rates_total-1-i;
      if(CopyHigh(_Symbol,_Period,s,MAperiod,hi)<=0){return(0);}
      if(CopyLow(_Symbol,_Period,s,MAperiod,lo)<=0){return(0);}
      double ydi=P[i]-M[i]+50;
      double h=NormalizeDouble(hi[ArrayMaximum(hi)],_Digits-1);
      double l=NormalizeDouble(lo[ArrayMinimum(lo)],_Digits-1);
      C[i]=(h-l)*ydi*0.01+l;
     }
   for(i=limit;i<rates_total;i++)
     {
      double sum=0.0;
      for(int j=0;j<MAperiod;j++)
        {
         sum+=C[i-j];
        }
      D[i]=sum/MAperiod;
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
