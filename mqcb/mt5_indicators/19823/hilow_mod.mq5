//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Hi/lo mod (variation of hi/low indicator)"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_width2  2

//--- input parameters
input int inpPeriod=2; // Calculating period

//--- buffers and global variables declarations
double up[],down[],state[];
int _handleH,_handleL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,up,INDICATOR_DATA);
   SetIndexBuffer(1,down,INDICATOR_DATA);
   SetIndexBuffer(2,state,INDICATOR_CALCULATIONS);
//---
   _handleH = iMA(_Symbol,_Period,inpPeriod,1,MODE_SMA,PRICE_HIGH); if(_handleH==INVALID_HANDLE) {                             return(INIT_FAILED); }
   _handleL = iMA(_Symbol,_Period,inpPeriod,1,MODE_SMA,PRICE_LOW);  if(_handleL==INVALID_HANDLE) { IndicatorRelease(_handleH); return(INIT_FAILED); }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Hi/lo mod ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(_handleH!=INVALID_HANDLE) IndicatorRelease(_handleH);
   if(_handleL!=INVALID_HANDLE) IndicatorRelease(_handleL);
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

   double _valh[1],_vall[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int _valhCopied = CopyBuffer(_handleH,0,rates_total-i-1,1,_valh); if(_valhCopied!=1) continue;
      int _vallCopied = CopyBuffer(_handleL,0,rates_total-i-1,1,_vall); if(_vallCopied!=1) continue;
      state[i]=(i>0) ? state[i-1]: 0;
      if(close[i]<_valh[0]) state[i] = -1;
      if(close[i]>_vall[0]) state[i] =  1;
      up[i]   = (state[i]==-1) ? _valh[0]+2*_Point : EMPTY_VALUE;
      down[i] = (state[i]== 1) ? _vall[0]-2*_Point : EMPTY_VALUE;
     }
   return (i);
  }
//+------------------------------------------------------------------+
