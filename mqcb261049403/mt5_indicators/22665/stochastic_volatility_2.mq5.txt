//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#resource "Stochastic volatility base 2.ex5"
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Stochastic volatility"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrOrangeRed
#property indicator_width3  2
#property indicator_label4  "Signal"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT

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
input string             UniqueID           = "Stochastic volatility"; // Unique ID for comunications

double val[],valc[],signal[],levelUp[],levelDn[],avg[],dev[];
int _hbp,_hsi,_hav,_hsd; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer( 0,levelUp,INDICATOR_DATA);
   SetIndexBuffer( 1,levelDn,INDICATOR_DATA);
   SetIndexBuffer( 2,val    ,INDICATOR_DATA);
   SetIndexBuffer( 3,valc   ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer( 4,signal ,INDICATOR_DATA);
   SetIndexBuffer( 5,avg    ,INDICATOR_CALCULATIONS);
   SetIndexBuffer( 6,dev    ,INDICATOR_CALCULATIONS);
   
   //
   //---
   //

   _hbp = iCustom(_Symbol,0,"::Stochastic volatility base 2.ex5",Length,Slowing,Price,OriginalStoch,OriginalVolatility); if (!_checkHandle(_hbp,"Base indicator 2")) return(INIT_FAILED);
   _hsi =     iMA(_Symbol,0,Signal     ,0,MODE_SMA,_hbp);                                                                if (!_checkHandle(_hsi,"Signal"))           return(INIT_FAILED);
   _hav =     iMA(_Symbol,0,BandsLength,0,MODE_SMA,_hbp);                                                                if (!_checkHandle(_hav,"Bands average"))    return(INIT_FAILED);
   _hsd = iStdDev(_Symbol,0,BandsLength,0,MODE_SMA,_hbp);                                                                if (!_checkHandle(_hsd,"Bands deviation"))  return(INIT_FAILED);
   
   IndicatorSetString(INDICATOR_SHORTNAME,UniqueID+" ("+(string)Length+","+(string)Slowing+","+(string)Signal+")");
   return(INIT_SUCCEEDED);
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
   if(BarsCalculated(_hbp)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsi)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hav)<rates_total) return(prev_calculated);
   if(BarsCalculated(_hsd)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
            if (CopyBuffer(_hbp,0,0,_copyCount,val)   !=_copyCount) { Comment("Error copying val"); return(prev_calculated); }
            if (CopyBuffer(_hsi,0,0,_copyCount,signal)!=_copyCount) { Comment("Error copying signal"); return(prev_calculated); }
            if (CopyBuffer(_hav,0,0,_copyCount,avg)   !=_copyCount) { Comment("Error copying avg"); return(prev_calculated); }
            if (CopyBuffer(_hsd,0,0,_copyCount,dev)   !=_copyCount) { Comment("Error copying dev"); return(prev_calculated); }

   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      levelUp[i] = avg[i]+dev[i]*BandsDeviation;
      levelDn[i] = avg[i]-dev[i]*BandsDeviation;
      valc[i]    = (val[i]<levelDn[i]) ? 1 : 0;
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
