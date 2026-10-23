//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Momentum of average"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Level down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Momentum of average"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width3  2

//
//--- input parameters
//
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on levels crossing
   cchange_on100     // Change color on 100 crossing
};
input int                inpMomPeriod   = 32;               // Momentum period
input int                inpMaPeriod    = 14;               // Average period (<= 1 for no average)
input ENUM_MA_METHOD     inpMaMethod    = MODE_EMA;         // Average method
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 
input double             inpLevelPeriod = 14;               // Levels period
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color change type

//
//--- buffers declarations
//

double val[],valc[],lup[],ldn[];

//
//--- indicator handles
//

int ª_maHandle,ª_maPeriod,ª_momHandle; double ª_alphal,ª_lvlPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,lup ,INDICATOR_DATA);
         SetIndexBuffer(1,ldn ,INDICATOR_DATA);
         SetIndexBuffer(2,val ,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);

         if (inpColorChange==cchange_on100)
         {
               IndicatorSetInteger(INDICATOR_LEVELS,1);
               IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100);
         }
         else  IndicatorSetInteger(INDICATOR_LEVELS,1);

   //--- indicator short name assignment
         ª_lvlPeriod = inpLevelPeriod>1 ? inpLevelPeriod :1;
         ª_alphal    = 2.0/(1.0+ª_lvlPeriod);
         ª_maPeriod  = inpMaPeriod>0 ? inpMaPeriod : 1;
         ª_maHandle  = iMA(_Symbol,0,ª_maPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average"))   return(INIT_FAILED);
         ª_momHandle = iMomentum(_Symbol,0,inpMomPeriod,ª_maHandle);     if (!_checkHandle(ª_momHandle,"Momentum")) return(INIT_FAILED);
   IndicatorSetString(INDICATOR_SHORTNAME,"Momentum of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpMomPeriod+","+(string)ª_maPeriod+","+(string)ª_lvlPeriod+")");
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
         if (CopyBuffer(ª_momHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (val[i]==EMPTY_VALUE) val[i] = 0;
         switch (inpColorChange)
         {
            case cchange_onLevels : lup[i]  = (i>0) ? (val[i]<ldn[i-1]) ? lup[i-1] : lup[i-1]+ª_alphal*(val[i]-lup[i-1]) : val[i];
                                    ldn[i]  = (i>0) ? (val[i]>lup[i-1]) ? ldn[i-1] : ldn[i-1]+ª_alphal*(val[i]-ldn[i-1]) : val[i];
                                    valc[i] = (val[i]>lup[i]) ? 1 :(val[i]<ldn[i]) ? 2 : 0; break;
            case cchange_onSlope  : lup[i] = ldn[i] = EMPTY_VALUE; valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_on100    : lup[i] = ldn[i] = EMPTY_VALUE; valc[i] = (val[i]>100) ? 1 :(val[i]<100) ? 2 : 0; break;
         }
   }
   return (i);
}
  
//------------------------------------------------------------------
//    custom functions
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
