//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Fast ema Hull high"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2
#property indicator_label2  "Fast ema Hull close"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width2  2
#property indicator_label3  "Fast ema Hull low"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width3  2
//--- input parameters
input double inpHullPeriod=27;  // Fast ema Hull period
//--- indicator buffers
double hullu[],hulluc[],hullc[],hullcc[],hulld[],hulldc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,hullu,INDICATOR_DATA);
   SetIndexBuffer(1,hulluc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,hullc,INDICATOR_DATA);
   SetIndexBuffer(3,hullcc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,hulld,INDICATOR_DATA);
   SetIndexBuffer(5,hulldc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Triple fast ema Hull ("+(string)inpHullPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      hullu[i] = iHulle(high[i] ,inpHullPeriod,i,0);
      hullc[i] = iHulle(close[i],inpHullPeriod,i,1);
      hulld[i] = iHulle(low[i]  ,inpHullPeriod,i,2);
      hulluc[i] = (i>0) ? (hullu[i]>hullu[i-1]) ? 2 : (hullu[i]<hullu[i-1]) ? 1 : hulluc[i-1] : 0;
      hullcc[i] = (i>0) ? (hullc[i]>hullc[i-1]) ? 2 : (hullc[i]<hullc[i-1]) ? 1 : hullcc[i-1] : 0;
      hulldc[i] = (i>0) ? (hulld[i]>hulld[i-1]) ? 2 : (hulld[i]<hulld[i-1]) ? 1 : hulldc[i-1] : 0;
     }
   return(i);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _ehullInstances 3
#define _ehullInstancesSize 3
#define _ehullRingSize 5
double workHulle[_ehullRingSize][_ehullInstances*_ehullInstancesSize];
//
//---
//
double iHulle(double price,double period,int i, int instance=0)
{
   int _indP = (i-1)%_ehullRingSize;
   int _indC = (i  )%_ehullRingSize;
   int _inst = instance*_ehullInstancesSize;
   
   //
   //---
   //
   
   if(i>0 && period>1)
   {
      #define _alpha(_period) (2.0/(2.0+(_period-1.0)/2.0))
         workHulle[_indC][_inst  ] = (i>0) ? workHulle[_indP][_inst  ]+_alpha(         period/2.0)*(price                                              -workHulle[_indP][_inst  ]) : price;
         workHulle[_indC][_inst+1] = (i>0) ? workHulle[_indP][_inst+1]+_alpha(         period    )*(price                                              -workHulle[_indP][_inst+1]) : price;
         workHulle[_indC][_inst+2] = (i>0) ? workHulle[_indP][_inst+2]+_alpha(MathSqrt(period)   )*(2*workHulle[_indC][_inst]-workHulle[_indC][_inst+1]-workHulle[_indP][_inst+2]) : price;
   }      
   else for(int k=0; k<_ehullInstancesSize; k++) workHulle[_indC][k+_inst] = (i>0) ? workHulle[_indP][k+_inst]: price;      
   return(workHulle[_indC][_inst+2]);
   
   //
   //---
   //
   
   #undef _alpha
}
//+------------------------------------------------------------------+
