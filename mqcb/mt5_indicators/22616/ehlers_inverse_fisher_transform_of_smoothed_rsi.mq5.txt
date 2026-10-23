//------------------------------------------------------------------
#property copyright    "© mladen, 2018"
#property link         "mladenfx@gmail.com"
#property version      "1.00"
#property description  "."
#property description  "Ehlers inverse fisher transform of"
#property description  "smoothed RSI with floating levels"
#property description  "."
#property description  "set the floating levels period to less than or equal to 1"
#property description  "to have classical fixed levels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   5

#property indicator_label1  "ift OB/OS zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'209,243,209',C'255,230,183'
#property indicator_label2  "ift up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "ift middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "ift down level"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_DOT
#property indicator_label5  "ift"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrLimeGreen,clrOrange
#property indicator_width5  2
//
//---
//
enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onMiddle,  // Change color on middle line cross
   cc_onLevels   // Change color on outer levels cross
};
input int                inpRsiPeriod     =  32;         // RSI period
input int                inpMaPeriod      =   9;         // Average period (<=1 for no average)
input ENUM_MA_METHOD     inpMaMethod      = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price 
input enColorOn          inpColorOn       = cc_onLevels; // Color change :
input int                inpMinMaxPeriod  = 50;          // Floating levels period (<= 1 for fixed levels)
input double             inpLevelUp       = 80.0;        // Up level %
input double             inpLevelDown     = 20.0;        // Down level %
//
//---
//
double rsi[],rsic[],fill1[],fill2[],levelUp[],levelMi[],levelDn[];
int _maHandle,_rsiHandle,_maPeriod;

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
   //---- indicator buffers mapping
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,levelUp,INDICATOR_DATA);
   SetIndexBuffer(3,levelMi,INDICATOR_DATA);
   SetIndexBuffer(4,levelDn,INDICATOR_DATA);
   SetIndexBuffer(5,rsi    ,INDICATOR_DATA);
   SetIndexBuffer(6,rsic   ,INDICATOR_COLOR_INDEX);
         for (int i=0; i<4; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   //---
         _maPeriod  = MathMax(inpMaPeriod,1);
         _rsiHandle = iRSI(_Symbol,0,inpRsiPeriod,inpPrice);             if (!_checkHandle(_rsiHandle)) return(INIT_FAILED);
         _maHandle  = iMA(_Symbol,0,_maPeriod,0,inpMaMethod,_rsiHandle); if (!_checkHandle(_maHandle))  return(INIT_FAILED);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"Ehlers ift of smoothed RSI ("+(string)inpRsiPeriod+","+(string)_maPeriod+")");
   return(0);
}

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if(BarsCalculated(_rsiHandle)<rates_total) return(prev_calculated);
   if(BarsCalculated(_maHandle)<rates_total)  return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
            if (CopyBuffer(_maHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double trss = (rsi[i]-50.0)*0.1;         
            rsi[i] = (MathExp(2.0*trss)-1.0)/(MathExp(2.0*trss)+1.0);
            if (inpMinMaxPeriod<=1)
            {                     
               levelUp[i] = 2.0*inpLevelUp  /100.0-1.0;
               levelDn[i] = 2.0*inpLevelDown/100.0-1.0;
               levelMi[i] = (levelUp[i]+levelDn[i])/2;
            }
            else
            {               
               int    start = MathMax(i-inpMinMaxPeriod+1,0);
               double max   = rsi[ArrayMaximum(rsi,start,inpMinMaxPeriod)];            
               double min   = rsi[ArrayMinimum(rsi,start,inpMinMaxPeriod)];            
               double range  = (max-min)/100.0;
                  levelUp[i] = min+inpLevelUp  *range;
                  levelDn[i] = min+inpLevelDown*range;
                  levelMi[i] = min+50.0        *range;
            }               
            switch(inpColorOn)
            {
               case cc_onLevels: rsic[i] = (rsi[i]>levelUp[i])  ? 1 : (rsi[i]<levelDn[i])  ? 2 : (i>0) ? (rsi[i]==rsi[i-1]) ? rsic[i-1] : 0 : 0; break;
               case cc_onMiddle: rsic[i] = (rsi[i]>levelMi[i])  ? 1 : (rsi[i]<levelMi[i])  ? 2 : 0; break;
               default :         rsic[i] = (i>0) ? (rsi[i]>rsi[i-1]) ? 1 : (rsi[i]<rsi[i-1]) ? 2 : (i>0) ? (rsi[i]==rsi[i-1]) ? rsic[i-1] : 0 : 0 : 0;
            }                  
            fill1[i] = rsi[i];
            fill2[i] = (rsi[i]>levelUp[i]) ? levelUp[i] : (rsi[i]<levelDn[i]) ? levelDn[i] : rsi[i];
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
bool _checkHandle(int _handle)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer) 
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); }
   return(_answer);
}  