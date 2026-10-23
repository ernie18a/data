//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "MinMax"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_style1  STYLE_DOT
#property indicator_label2  "MinMax"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Midle"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//--- input parameters
//

input int                inpPeriod = 25;          // MinMax period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double valu[],valuc[],vald[],valdc[],valm[],valmc[],prices[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
   
         SetIndexBuffer(0,valu  ,INDICATOR_DATA);
         SetIndexBuffer(1,valuc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,vald  ,INDICATOR_DATA);
         SetIndexBuffer(3,valdc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,valm  ,INDICATOR_DATA);
         SetIndexBuffer(5,valmc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,prices,INDICATOR_COLOR_INDEX);
   //            
   //--- indicator short name assignment
   //
   
         IndicatorSetString(INDICATOR_SHORTNAME,"MinMax ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom pseudo function(s)
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
   }}

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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
      int    _start = i-inpPeriod+1; if (_start<0) _start=0;
      double _max   = prices[ArrayMaximum(prices,_start,inpPeriod)];            
      double _min   = prices[ArrayMinimum(prices,_start,inpPeriod)];   

      //
      //---
      //
                  
      valu[i] = _max; valuc[i] = (i>0) ?(valu[i]>valu[i-1]) ? 1 :(valu[i]<valu[i-1]) ? 2 : valuc[i-1]: 0;
      vald[i] = _min; valdc[i] = (i>0) ?(vald[i]>vald[i-1]) ? 1 :(vald[i]<vald[i-1]) ? 2 : valdc[i-1]: 0;
      valm[i] = (_min+_max)/2.0; valmc[i] = (i>0) ?(valm[i]>valm[i-1]) ? 1 :(valm[i]<valm[i-1]) ? 2 : valmc[i-1]: 0;
   }
   return(i);
}
