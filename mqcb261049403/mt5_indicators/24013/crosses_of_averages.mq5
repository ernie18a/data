//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Average crosses signals"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Signals"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrMediumSeaGreen,clrOrangeRed
#property indicator_minimum 0
#property indicator_maximum 1
//
//--- input parameters
//
input int                inpFastMaPeriod =  12;             // Fast average period
input int                inpSlowMaPeriod =  26;             // Slow average period
input ENUM_MA_METHOD     inpMaMethod     = MODE_EMA;         // Average method
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;      // Price 

//
//--- buffers declarations
//

double sigup[],sigdn[],cross[],mafast[],maslow[]; 
int ª_maFastHandle,ª_maSlowHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,sigup ,INDICATOR_DATA);
         SetIndexBuffer(1,sigdn ,INDICATOR_DATA);
         SetIndexBuffer(2,cross ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,mafast,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,maslow,INDICATOR_CALCULATIONS);
   //
   //--- indicator short name assignment
   //
         ª_maFastHandle  = iMA(_Symbol,0,inpFastMaPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maFastHandle,"Fast average")) { return(INIT_FAILED); }
         ª_maSlowHandle  = iMA(_Symbol,0,inpSlowMaPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maSlowHandle,"Slow average")) { return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,StringSubstr(EnumToString(inpMaMethod),5,-1)+" crosses signals ("+(string)inpFastMaPeriod+","+(string)inpSlowMaPeriod+")");
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
         if (CopyBuffer(ª_maFastHandle,0,0,_copyCount,mafast)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maSlowHandle,0,0,_copyCount,maslow)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      cross[i] = (mafast[i]>maslow[i]) ? 1 : (mafast[i]<maslow[i]) ? -1 : (i>0) ? cross[i-1] : 0;
      sigup[i] = sigdn[i] = 0;
      if (i>0)
         if (cross[i]!=cross[i-1])
         {
            if (cross[i]== 1) sigup[i] = 1;
            if (cross[i]==-1) sigdn[i] = 1;
         }
         else
         {
            if (cross[i]== 1) sigup[i] = 0.02;
            if (cross[i]==-1) sigdn[i] = 0.02;
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
