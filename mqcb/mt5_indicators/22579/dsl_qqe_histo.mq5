//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Discontinued signal line QQE histo"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   6
#property indicator_label1  "QQE histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrGainsboro,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "QQE fast"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_style4  STYLE_DOT
#property indicator_label5  "QQE slow"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_label6  "QQE"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width6  2
//
//--- input parameters
//
input int                inpRsiPeriod          = 14;          // RSI period
input int                inpRsiSmoothingFactor =  5;          // RSI smoothing factor
input double             inpWPFast             = 2.618;       // Fast period
input double             inpWPSlow             = 4.236;       // Slow period
input ENUM_APPLIED_PRICE inpPrice              = PRICE_CLOSE; // Price 
input double             inpSignalPeriod       = 9;           // DSL signal period
//
//--- buffers declarations
//
double val[],valc[],levup[],levdn[],levs[],levf[],histoh[],histol[],histoc[],rsi[];
int _rsiHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,histoh,INDICATOR_DATA);
         SetIndexBuffer(1,histol,INDICATOR_DATA);
         SetIndexBuffer(2,histoc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(3,levup ,INDICATOR_DATA);
         SetIndexBuffer(4,levdn ,INDICATOR_DATA);
         SetIndexBuffer(5,levf  ,INDICATOR_DATA);
         SetIndexBuffer(6,levs  ,INDICATOR_DATA);
         SetIndexBuffer(7,val   ,INDICATOR_DATA);
         SetIndexBuffer(8,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(9,rsi   ,INDICATOR_CALCULATIONS);
   //--- indicator(s) loading
         _rsiHandle=iRSI(_Symbol,0,inpRsiPeriod,inpPrice); if (!_checkHandle(_rsiHandle)) return(INIT_FAILED);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"DSL QQE histo ("+(string)inpRsiPeriod+","+(string)inpRsiSmoothingFactor+","+(string)inpSignalPeriod+")");
   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
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
   if(BarsCalculated(_rsiHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
            if (CopyBuffer(_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      val[i] = histoh[i] = iEma(rsi[i]!=EMPTY_VALUE?rsi[i]:0,inpRsiSmoothingFactor,i,0);
      double _iEma = iEma((i>0 ? MathAbs(val[i-1]-val[i]) : 0),inpRsiPeriod,i,1);
      double _iEmm = iEma(                               _iEma,inpRsiPeriod,i,2);
      double _iEmf = _iEmm*inpWPFast;
      double _iEms = _iEmm*inpWPSlow;
      
      //
      //---
      //
      
      {
         double tr = (i>0) ? levs[i-1] : 0;
         double dv = tr;
         if(val[i]<tr) { tr=val[i]+_iEms; if (i>0 && val[i-1]<dv && tr>dv) tr = dv; }
         if(val[i]>tr) { tr=val[i]-_iEms; if (i>0 && val[i-1]>dv && tr<dv) tr = dv; }
               levs[i]=tr;
      }
      {
         double tr = (i>0) ? levf[i-1] : 0;
         double dv = tr;
         if(val[i]<tr) { tr=val[i]+_iEmf; if (i>0 && val[i-1]<dv && tr > dv) tr = dv; }
         if(val[i]>tr) { tr=val[i]-_iEmf; if (i>0 && val[i-1]>dv && tr < dv) tr = dv; }
               levf[i]=tr;
      }
      histol[i] = 50;    
      levup[i]  = iEma(val[i],inpSignalPeriod,i,3,val[i]<50.0);
      levdn[i]  = iEma(val[i],inpSignalPeriod,i,4,val[i]>50.0);
      valc[i]   = (val[i]>levf[i] && val[i]>levs[i]) ? 1 :(val[i]<levf[i] && val[i]<levs[i]) ? 2 :(i>0) ? valc[i-1]: 0;
      histoc[i] = (val[i]>levup[i]) ? 1 :(val[i]<levdn[i]) ? 2 :0;
   }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _emaInstances 5
#define _emaRingSize 6
double workEma[_emaRingSize][_emaInstances];
//
//---
//
double iEma(double price, double period,int i, int _inst=0, bool copy=false)
{
   int _indC = (i  )%_emaRingSize;
   int _indP = (i-1)%_emaRingSize;

   if(!copy && i>0 && period>1)
          workEma[_indC][_inst] = workEma[_indP][_inst]+(2.0/(1.0+period))*(price-workEma[_indP][_inst]);
   else   workEma[_indC][_inst] = (i>0) ? workEma[_indP][_inst] : price;
   return(workEma[_indC][_inst]);
}
//
//---
//
bool _checkHandle(int _handle)
{
   static int _handles[];
          int _size = ArraySize(_handles);
          
          if (_handle!=INVALID_HANDLE) 
          { 
               ArrayResize(_handles,_size+1); 
                           _handles[_size]=_handle; 
                                 return(true); 
          }
          for (int i=_size-1; i>0; i--)
               IndicatorRelease(_handles[i]);
          return(false);
}  
//+------------------------------------------------------------------+