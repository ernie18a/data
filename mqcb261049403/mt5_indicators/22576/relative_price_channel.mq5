//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Relative Price Channel"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   7
#property indicator_label1  "Lower filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLinen,clrLinen
#property indicator_label2   "Upper filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrPaleGreen,clrPaleGreen,
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSilver
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSilver
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrSilver
#property indicator_width7  2
//
//--- input parameters
//
input int                inpRsiPeriod        = 14;          // RSI period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // RSI price 
input int                inpSmoothing        = 14;          // Smoothing period for RSI
input double             inpOverbought       = 70;          // Overbought level %
input double             inpOversold         = 30;          // Oversold level %
input double             inpUpperNeutral     = 55;          // Upper neutral level %
input double             inpLowerNeutral     = 45;          // Lower neutral level %
//
//--- buffers declarations
//
double filluu[],fillud[],filldu[],filldd[],bupu[],bupd[],bdnu[],bdnd[],rsi[];
//
//--- indicator handles
//
int _rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,filluu,INDICATOR_DATA);
   SetIndexBuffer(1,fillud,INDICATOR_DATA);
   SetIndexBuffer(2,filldu,INDICATOR_DATA);
   SetIndexBuffer(3,filldd,INDICATOR_DATA);
   SetIndexBuffer(4,bupu,INDICATOR_DATA);
   SetIndexBuffer(5,bupd,INDICATOR_DATA);
   SetIndexBuffer(6,bdnu,INDICATOR_DATA);
   SetIndexBuffer(7,bdnd,INDICATOR_DATA);
   SetIndexBuffer(8,rsi,INDICATOR_DATA);
      for (int i=0; i<6; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
//--- indicator short name assignment
   _rsiHandle=iRSI(_Symbol,0,inpRsiPeriod,inpPrice); if(_rsiHandle==INVALID_HANDLE) return(INIT_FAILED);
   IndicatorSetString(INDICATOR_SHORTNAME,"RPC ("+(string)inpRsiPeriod+","+(string)inpSmoothing+")");
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
   if(BarsCalculated(_rsiHandle)<rates_total) return(prev_calculated);
   
      //
      //---
      //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
         if (CopyBuffer(_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);
   
      //
      //---
      //
      
      int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
      {
         double _rsi = (rsi[i]!=EMPTY_VALUE) ? rsi[i] : 0;
         double _ob  = iEma(_rsi-inpOverbought  ,inpSmoothing,i,0);
         double _os  = iEma(_rsi-inpOversold    ,inpSmoothing,i,1);
         double _nzu = iEma(_rsi-inpUpperNeutral,inpSmoothing,i,2);
         double _nzd = iEma(_rsi-inpLowerNeutral,inpSmoothing,i,3);
         
         filluu[i] = bupu[i] = _ob;
         fillud[i] = bupd[i] = _nzu;
         filldu[i] = bdnu[i] = _os;
         filldd[i] = bdnd[i] = _nzd;
         rsi[i] -= 50;
     }
   return (i);
}
  
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _emaInstances 4
#define _emaRingSize 6
double workEma[_emaRingSize][_emaInstances];
//
//---
//
double iEma(double price, double period,int i, int _inst=0)
{
   int _indC = (i  )%_emaRingSize;
   int _indP = (i-1)%_emaRingSize;

   if(i>0 && period>1)
          workEma[_indC][_inst]=workEma[_indP][_inst]+(2.0/(1.0+period))*(price-workEma[_indP][_inst]);
   else   workEma[_indC][_inst]=price;
   return(workEma[_indC][_inst]);
}