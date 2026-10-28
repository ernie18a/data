//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TRIX candles with \"Keltner\" channels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   4
#property indicator_label1  "TRiX"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_label2  "average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "channel up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "channel up"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT

input int    inpPeriod     = 14;  // TRiX period
input int    inpAvgPeriod  = 0;   // Channel period (<=1 for same as TRiX period)
input double inpMultiplier = 1.5; // Channels multiplier

//
//--- indicator buffers
//
double valo[],valh[],vall[],valc[],valcl[],kel[],kelu[],keld[],tr[],trix[],atr[],avg[],ª_workVal[4];
int ª_valhHandle,ª_vallHandle,ª_valoHandle,ª_valcHandle,ª_avgPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer( 0,valo ,INDICATOR_DATA);
         SetIndexBuffer( 1,valh ,INDICATOR_DATA);
         SetIndexBuffer( 2,vall ,INDICATOR_DATA);
         SetIndexBuffer( 3,valc ,INDICATOR_DATA);
         SetIndexBuffer( 4,valcl,INDICATOR_COLOR_INDEX);
         SetIndexBuffer( 5,kel  ,INDICATOR_DATA);
         SetIndexBuffer( 6,kelu ,INDICATOR_DATA);
         SetIndexBuffer( 7,keld ,INDICATOR_DATA);
         SetIndexBuffer( 8,tr   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer( 9,atr  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(10,trix ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(11,avg  ,INDICATOR_CALCULATIONS);

         //
         //---
         //
         
         ª_valhHandle = iTriX(_Symbol,0,inpPeriod,PRICE_HIGH);  if (!_checkHandle(ª_valhHandle,"TRiX of high"))  return(INIT_FAILED);
         ª_vallHandle = iTriX(_Symbol,0,inpPeriod,PRICE_LOW );  if (!_checkHandle(ª_vallHandle,"TRiX of low"))   return(INIT_FAILED);
         ª_valoHandle = iTriX(_Symbol,0,inpPeriod,PRICE_OPEN);  if (!_checkHandle(ª_valoHandle,"TRiX of open"))  return(INIT_FAILED);
         ª_valcHandle = iTriX(_Symbol,0,inpPeriod,PRICE_CLOSE); if (!_checkHandle(ª_valcHandle,"TRiX of close")) return(INIT_FAILED);
         ª_avgPeriod  = (inpAvgPeriod>1) ? inpAvgPeriod : inpPeriod;
   //
   //---
   //      
   
   IndicatorSetString(INDICATOR_SHORTNAME,"TRiX candles ("+(string)inpPeriod+","+(string)ª_avgPeriod+","+(string)inpMultiplier+")");
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
      if (vall[i] == EMPTY_VALUE) vall[i]=0;
      if (valh[i] == EMPTY_VALUE) valh[i]=0;
      if (valo[i] == EMPTY_VALUE) valo[i]=0;
      if (valc[i] == EMPTY_VALUE) valc[i]=0;
                   ª_workVal[1] = vall[i]; 
                   ª_workVal[0] = valh[i]; 
                   ª_workVal[2] = valo[i]; 
                   ª_workVal[3] = valc[i]; 
                                  valh[i] = ª_workVal[ArrayMaximum(ª_workVal)];
                                  vall[i] = ª_workVal[ArrayMinimum(ª_workVal)];
         
         //
         //---
         //
         
         trix[i] = (valh[i]+vall[i]+valo[i]+valc[i])/4.0;
         tr[i]   = (i>0) ? MathMax(valh[i],valc[i-1])-MathMin(vall[i],valc[i-1]) : valh[i]-vall[i];
         if (i>ª_avgPeriod)
            {
               avg[i] = avg[i-1]+trix[i]-trix[i-ª_avgPeriod];
               atr[i] = atr[i-1]+tr[i]-tr[i-ª_avgPeriod];
            }
         else
            {
               avg[i] = atr[i] = 0;
               for (int k=0; k<ª_avgPeriod && i>=k; k++)
               {
                  avg[i] += trix[i-k];
                  atr[i] += tr[i-k];
               }
            }            
         kel[i]  = avg[i]/(double)ª_avgPeriod;
         kelu[i] = kel[i]+inpMultiplier*atr[i]/(double)ª_avgPeriod;
         keld[i] = kel[i]-inpMultiplier*atr[i]/(double)ª_avgPeriod;
         valcl[i]= (valc[i]>valo[i]) ? 1 : (valc[i]<valo[i]) ? 2 : 0;
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