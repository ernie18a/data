//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TRIX candles"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "TRIX"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrMediumSeaGreen,clrOrangeRed

input int inpPeriod  = 14;  // TRIX period

//
//--- indicator buffers
//
double valo[],valh[],vall[],valc[],valcl[],ª_workVal[4];
int ª_valhHandle,ª_vallHandle,ª_valoHandle,ª_valcHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,valo,INDICATOR_DATA);
         SetIndexBuffer(1,valh,INDICATOR_DATA);
         SetIndexBuffer(2,vall,INDICATOR_DATA);
         SetIndexBuffer(3,valc,INDICATOR_DATA);
         SetIndexBuffer(4,valcl,INDICATOR_COLOR_INDEX);

         ª_valhHandle = iTriX(_Symbol,0,inpPeriod,PRICE_HIGH);  if (!_checkHandle(ª_valhHandle,"TRIX of high"))  return(INIT_FAILED);
         ª_vallHandle = iTriX(_Symbol,0,inpPeriod,PRICE_LOW );  if (!_checkHandle(ª_vallHandle,"TRIX of low"))   return(INIT_FAILED);
         ª_valoHandle = iTriX(_Symbol,0,inpPeriod,PRICE_OPEN);  if (!_checkHandle(ª_valoHandle,"TRIX of open"))  return(INIT_FAILED);
         ª_valcHandle = iTriX(_Symbol,0,inpPeriod,PRICE_CLOSE); if (!_checkHandle(ª_valcHandle,"TRIX of close")) return(INIT_FAILED);
   //
   //---
   //      
   
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX candles ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_valhHandle,0,0,_copyCount,valh)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_vallHandle,0,0,_copyCount,vall)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_valoHandle,0,0,_copyCount,valo)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_valcHandle,0,0,_copyCount,valc)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      ª_workVal[1] = vall[i];
      ª_workVal[0] = valh[i];
      ª_workVal[2] = valo[i];
      ª_workVal[3] = valc[i];
         valh[i] = ª_workVal[ArrayMaximum(ª_workVal)];
         vall[i] = ª_workVal[ArrayMinimum(ª_workVal)];
         valcl[i]=(valc[i]>valo[i]) ? 1 :(valc[i]<valo[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//+------------------------------------------------------------------+