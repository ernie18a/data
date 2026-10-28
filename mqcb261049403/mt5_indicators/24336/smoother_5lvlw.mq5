//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "DSMA"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width3  2

//
//---
//

input int                inpPeriod  = 27;          // Period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//---
//

double val[],valc[],levelUp[],levelDn[];

//------------------------------------------------------------------
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,levelUp,INDICATOR_DATA); 
         SetIndexBuffer(1,levelDn,INDICATOR_DATA);
         SetIndexBuffer(2,val    ,INDICATOR_DATA);
         SetIndexBuffer(3,valc   ,INDICATOR_COLOR_INDEX);
            PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
            PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
               iSmoother.init(inpPeriod);
               iSmootherUp.init(inpPeriod);
               iSmootherDn.init(inpPeriod);
   //
   //---
   //         
   IndicatorSetString(INDICATOR_SHORTNAME,"Smoother levels ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      val[i]     = iSmoother.calculate(_price,i,rates_total,false);
      levelUp[i] = iSmootherUp.calculate(val[i],i,rates_total,(i>0 ? !(val[i]>levelDn[i-1]) : false));
      levelDn[i] = iSmootherDn.calculate(val[i],i,rates_total,(i>0 ? !(val[i]<levelUp[i-1]) : false));
      valc[i]    = (val[i]>=levelUp[i]) ? 1 : (val[i]<=levelDn[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CSmoother
{
   private :
      double m_period;
      double m_alpha;
      double m_beta;
      int    m_arraySize;
      struct CSmootherStruct
      {
         double l0;
         double l1;
         double l2;
         double l3;
         double l4;
      };
      CSmootherStruct m_array[];
   public :
      CSmoother() : m_arraySize(-1), m_alpha(1), m_beta(1) {}
     ~CSmoother() {}
   
      //
      //
      //
      
      bool init(double period)
      {
         m_period = (period>1) ? period : 1;
         m_beta   = 0.45 * (m_period-1.0)/(0.45 * (m_period-1)+2.0);
         m_alpha  = m_beta*m_beta*m_beta;
            return(true);
      }
      
      double calculate(double value, int i, int bars, bool copy=false)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //
         //
                    
         if (i>0)
         {
            if (copy)
            {
               m_array[i].l0 = m_array[i-1].l0;
               m_array[i].l1 = m_array[i-1].l1;
               m_array[i].l2 = m_array[i-1].l2;
               m_array[i].l3 = m_array[i-1].l3;
               m_array[i].l4 = m_array[i-1].l4;
            }
            else
            {
               m_array[i].l0 = (1.0-m_alpha)*value + m_alpha*m_array[i-1].l0;
               m_array[i].l1 = (value-m_array[i].l0)*(1-m_beta) + m_beta*m_array[i-1].l1;
               m_array[i].l2 =  m_array[i].l0 + m_array[i].l1;
               m_array[i].l3 = (m_array[i].l2 - m_array[i-1].l4)*(1.0-m_alpha)*(1.0-m_alpha) + m_alpha*m_alpha*m_array[i-1].l3;
               m_array[i].l4 =  m_array[i-1].l4 + m_array[i].l3;
            }               
         }                    
         else { m_array[i].l0 = m_array[i].l1 = m_array[i].l4 = value; m_array[i].l2 = m_array[i].l3 = 0; }
         return(m_array[i].l4);
      }
};
CSmoother iSmoother,iSmootherUp,iSmootherDn;
//------------------------------------------------------------------