//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI of average - floating levels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Upper level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "CCI of average"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width4  2

//
//--- input parameters
//
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on levels crossing
   cchange_onZero    // Change color on zero crossing
};
input int                inpCciPeriod   =  32;              // CCI period
input int                inpMaPeriod    =  14;              // Average period (<= 1 for no average)
input ENUM_MA_METHOD     inpMaMethod    = MODE_EMA;         // Average method
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 
input int                inpFlPeriod   = 25;                // Floating levels period
input double             inpFlLevelUp  = 90;                // Floating levels up %
input double             inpFlLevelDn  = 10;                // Floating levels down %
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color change type

//
//--- buffers declarations
//

double val[],valc[],levu[],levd[],levm[]; 

//
//--- indicator handles
//

int ª_maHandle,ª_maPeriod,ª_cciHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,levu,INDICATOR_DATA);
         SetIndexBuffer(1,levm,INDICATOR_DATA);
         SetIndexBuffer(2,levd,INDICATOR_DATA);
         SetIndexBuffer(3,val ,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);

   //--- indicator short name assignment
         ª_maPeriod  = inpMaPeriod>0 ? inpMaPeriod : 1;
         ª_maHandle  = iMA(_Symbol,0,ª_maPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average")) { return(INIT_FAILED); }
         ª_cciHandle = iCCI(_Symbol,0,inpCciPeriod,ª_maHandle);          if (!_checkHandle(ª_cciHandle,"CCI"))    { return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpCciPeriod+","+(string)inpMaPeriod+")("+(string)inpFlPeriod+")");
   return (INIT_SUCCEEDED);
}

//
//---
//

void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_cciHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
         double _min,_max; _cciMinMax.calculate(val[i],val[i],inpFlPeriod,_min,_max,i);
         double range = (_max-_min)/100.0;
         levu[i] = _min+inpFlLevelUp*range;
         levd[i] = _min+inpFlLevelDn*range;
         levm[i] = (levu[i]+levd[i])/2;
   
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
   }         
   return (i);
}
  
//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cMinMax
{
   private :
      int    originalPeriod;
      int    period;
      int    prevbar;
      double currmin;
      double currmax;
      double prevmax;
      double prevmin;
      double minArray[];
      double maxArray[];
         
   public :
      cMinMax() { originalPeriod = prevbar = INT_MIN;       return; }
     ~cMinMax() { ArrayFree(minArray); ArrayFree(maxArray); return; }
     
      //
      //
      //
     
      void calculate(double valueMin, double valueMax, int forPeriod, double& min, double& max, int i)
      {
         if (prevbar!=i)
         {
            prevbar = i;
               if (originalPeriod!=forPeriod)
               {
                     originalPeriod =  forPeriod;
                     period         = (forPeriod>0) ? forPeriod : 1;
                     prevmin        = valueMin;
                     prevmax        = valueMax;
                     currmin        = valueMin;
                     currmax        = valueMax;
                           ArrayResize(minArray,period-1); ArrayInitialize(minArray,valueMin);
                           ArrayResize(maxArray,period-1); ArrayInitialize(maxArray,valueMax);
               }
               if (period>1)
               {
                  int _pos = (i) % (period-1);
                     minArray[_pos] = currmin;
                     maxArray[_pos] = currmax;
                     prevmin        = minArray[ArrayMinimum(minArray)];
                     prevmax        = maxArray[ArrayMaximum(maxArray)];
               }
               else  { prevmin = valueMin; prevmax = valueMax; }
         }

         //
         //
         //
            
         currmin = valueMin;
         currmax = valueMax;
            max = (prevmax>valueMax) ? prevmax : valueMax;
            min = (prevmin<valueMin) ? prevmin : valueMin;
         return;
     }
};
cMinMax _cciMinMax;

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
