//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Normalized RSI - extended"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   6
#property indicator_label1  "Upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,240,240'
#property indicator_label2  "Lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'240,255,240'
#property indicator_label3  "Upper level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Middle level"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Lower level"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_style5  STYLE_DOT
#property indicator_label6  "Rsi"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width6  2

//
//
//

enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on OB/OS level
   cchange_onZero    // Change color on level 50 cross
};
input int                inpRsiPeriod   = 32;          // RSI period
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input int                inpNormPeriod  = 100;         // Normalization period
input int                inpHlPeriod    = 25;          // Highest high/lowest low period
input double             inpHlLevelUp   = 70;          // OB level
input double             inpHlLevelDn   = 30;          // OS level
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color changing mode

//
//---
//

double val[],valc[],filluu[],fillud[],filldd[],filldu[],levu[],levd[],levm[],rsi[];
int  ª_rsiHandle,ª_rsiPeriod; 

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
         SetIndexBuffer(0,filluu,INDICATOR_DATA);
         SetIndexBuffer(1,fillud,INDICATOR_DATA);
         SetIndexBuffer(2,filldu,INDICATOR_DATA);
         SetIndexBuffer(3,filldd,INDICATOR_DATA);
         SetIndexBuffer(4,levm  ,INDICATOR_DATA);
         SetIndexBuffer(5,levu  ,INDICATOR_DATA);
         SetIndexBuffer(6,levd  ,INDICATOR_DATA);
         SetIndexBuffer(7,val   ,INDICATOR_DATA);
         SetIndexBuffer(8,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(9,rsi   ,INDICATOR_CALCULATIONS);
            ª_rsiPeriod   = (inpRsiPeriod>1) ? inpRsiPeriod : 1;
            ª_rsiHandle   = iRSI(_Symbol,0,ª_rsiPeriod,inpPrice); if (!_checkHandle(ª_rsiHandle,"RSI")) return(INIT_FAILED);
            
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI on chart ("+(string)inpRsiPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

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
         if (CopyBuffer(ª_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);

   //
   //---
   //

      static int    prev_i=-1;
      static double prev_maxr,prev_minr;

   //
   //
   //
   
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsi[i] == EMPTY_VALUE) rsi[i] = 0;
         if (prev_i!=i)
         {
            prev_i = i; 
            int start     = i-inpNormPeriod+1; if (start<0) start=0;
                prev_maxr = rsi[ArrayMaximum(rsi,start,inpNormPeriod-1)];
                prev_minr = rsi[ArrayMinimum(rsi,start,inpNormPeriod-1)];
         }
         double maxr   = (rsi[i] > prev_maxr) ? rsi[i] : prev_maxr;
         double minr   = (rsi[i] < prev_minr) ? rsi[i] : prev_minr;
         double ranger = (maxr-minr)/100.0;
   
            levu[i]   = inpHlLevelUp;
            levd[i]   = inpHlLevelDn;
            levm[i]   =           50;
            val[i]    = fillud[i] = filldu[i] = ((ranger!=0) ? (rsi[i]-minr)/ranger : rsi[i]);
            filluu[i] = 100;
            filldd[i] =   0;
         
         //
         //
         //
         
         switch (inpColorChange)
         {
            case cchange_onLevels : valc[i] = (val[i]>levu[i]) ? 1 :(val[i]<levd[i]) ? 2 : 0; break;
            case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case cchange_onZero   : valc[i] = (val[i]>levm[i]) ? 1 :(val[i]<levm[i]) ? 2 : 0; break;
         }         
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
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------