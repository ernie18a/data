//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#resource "Stochastic volatility 2.ex5"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "ranging candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_DOT

//
//--- input parameters
//

input int                Length             =  30;            // Stochastic period
input int                Slowing            =   5;            // Stochastic slowing
input int                Signal             =   5;            // Signal period
input int                BandsLength        = 126;            // Bands period
input double             BandsDeviation     =   1;            // Bands deviation
input ENUM_APPLIED_PRICE Price              = PRICE_CLOSE;    // Price
input bool               OriginalStoch      = true;           // Calculate using original stochastic
input bool               OriginalVolatility = true;           // Calculate using original volatility

double canh[],canl[],cano[],canc[],cancl[],valc[];
int _viHandle; string _shortName;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,cano,INDICATOR_DATA);
   SetIndexBuffer(1,canh,INDICATOR_DATA);
   SetIndexBuffer(2,canl,INDICATOR_DATA);
   SetIndexBuffer(3,canc,INDICATOR_DATA);
   SetIndexBuffer(4,cancl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,valc,INDICATOR_CALCULATIONS);
   
   //
   //---
   //

   string _uniqueID = "Stochastic volatility "+(string)MathRand(); _shortName = _uniqueID+" ("+(string)Length+","+(string)Slowing+","+(string)Signal+")";
   _viHandle = iCustom(_Symbol,0,"::Stochastic volatility 2.ex5",Length,Slowing,Signal,BandsLength,BandsDeviation,Price,OriginalStoch,OriginalVolatility,_uniqueID); if (!_checkHandle(_viHandle,"Stochastic volatility")) return(INIT_FAILED);
      ChartIndicatorAdd(0,(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL),_viHandle);   
      
   
   //
   //---
   //
            
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic volatility on chart ("+(string)Length+","+(string)Slowing+","+(string)Signal+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL); 
   for (int w=0; w<windows; w++) 
   { 
         int total=ChartIndicatorsTotal(0,w); 
         for(int i=0;i<total;i++) 
         { 
            string _name   = ChartIndicatorName(0,w,i); 
               if (_name==_shortName)
               {
                  ChartIndicatorDelete(0,w,_name);
                  ChartRedraw();
               } 
         }               
   } 
   IndicatorRelease(_viHandle);
}

//------------------------------------------------------------------
// Custom indicator iteration function
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
   if(BarsCalculated(_viHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
            if (CopyBuffer(_viHandle,3,0,_copyCount,valc)   !=_copyCount) { Comment("Error copying states"); return(prev_calculated); }

   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      cancl[i] = 0;
      if (valc[i] !=0)
      {
         canc[i] = close[i];
         cano[i] = open[i];
         canh[i] = high[i];
         canl[i] = low[i];
      }         
      else canc[i] = canh[i] = canl[i] = cano[i] = EMPTY_VALUE;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}    
//+------------------------------------------------------------------+
