//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Fill zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'225,255,225',C'255,225,225'
#property indicator_label2  "Range weighted average MACD"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrOrangeRed,clrMediumSeaGreen
#property indicator_width2  2
#property indicator_label3  "Range weighted average MACD signal"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrOrangeRed,clrMediumSeaGreen
#property indicator_style3  STYLE_DOT

//
//--- input parameters
//

input int                inpFastPeriod = 12;          // Fast period
input int                inpSlowPeriod = 26;          // Slow period
input int                inpSignPeriod = 9;           // Signal period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double valm[],valmc[],fillu[],filld[],vals[],valsc[]; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu,INDICATOR_DATA);
         SetIndexBuffer(1,filld,INDICATOR_DATA);
         SetIndexBuffer(2,valm ,INDICATOR_DATA);
         SetIndexBuffer(3,valmc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,vals ,INDICATOR_DATA);
         SetIndexBuffer(5,valsc,INDICATOR_COLOR_INDEX);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Range weighted average MACD ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+(string)inpSignPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

//
//---
//   

#define _calcAverage(_period,_price,_sump,_sumw) \
   if (i>_period) \
         {  m_array[i]._sump = m_array[i-1]._sump+m_array[i]._price-m_array[i-_period]._price; \
            m_array[i]._sumw = m_array[i-1]._sumw+m_array[i].weight-m_array[i-_period].weight; } \
   else  {  m_array[i]._sump = m_array[i]._price; \
            m_array[i]._sumw = m_array[i].weight; \
            for (int k=1; k<_period && i>=k; k++) \
            {  m_array[i]._sump += m_array[i-k]._price; \
               m_array[i]._sumw += m_array[i-k].weight; }} 

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
   struct sRwAverage
   {
      double weight;
      double price;
      double macd;
      double sumw1;
      double sump1;
      double sumw2;
      double sump2;
      double sumw3;
      double sump3;
   };
   static sRwAverage m_array[];
   static int        m_arraySize=0;
             if (m_arraySize<rates_total)
             {
                 int _res = ArrayResize(m_array,rates_total+500);
                 if (_res<=rates_total) return(prev_calculated);
                     m_arraySize = _res;
             }
   
   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      double _weight = high[i]-low[i]; if (_weight==0) _weight=_Point;
      
         //
         //---
         //
         
         m_array[i].weight = _weight;
         m_array[i].price  = _weight*_price;
            _calcAverage(inpFastPeriod,price,sump1,sumw1);
            _calcAverage(inpSlowPeriod,price,sump2,sumw2);
         m_array[i].macd = _weight*(m_array[i].sump1/m_array[i].sumw1-m_array[i].sump2/m_array[i].sumw2);
            _calcAverage(inpSignPeriod,macd,sump3,sumw3);
      valm[i] = m_array[i].sump1/m_array[i].sumw1-m_array[i].sump2/m_array[i].sumw2;
      vals[i] = m_array[i].sump3/m_array[i].sumw3;
      valmc[i] = valsc[i] = (valm[i]>vals[i]) ? 2 :(valm[i]<vals[i]) ? 1 : 0;
      filld[i] = 0; fillu[i] = valm[i]-vals[i];
   }
   return(i);
}