//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 40
#property indicator_plots   20

//
//--- input parameters
//
input double             inpStep        = 5;                 // Step
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;       // Price
input color              inpColorUp     = clrMediumSeaGreen; // Up slope color
input color              inpColorDn     = clrSandyBrown;     // Down slope color
input int                inpLinesWidth  = 0;                 // Lines width
input ENUM_LINE_STYLE    inpLinesStyle  = STYLE_SOLID;       // Lines style
//
//--- indicator buffers
//


struct simpleBuff
{
   double buffer[];
   double bufferColor[];
};
simpleBuff wbuffer[20];

//------------------------------------------------------------------
//
//------------------------------------------------------------------ 
//
//
//


int OnInit()
{
   //
   //--- indicator buffers mapping
   //

   double _step = inpStep>1 ? inpStep : 1.1;
   for (int i=0; i<20; i++)
   {
      SetIndexBuffer(i*2  ,wbuffer[i].buffer     ,INDICATOR_DATA);
      SetIndexBuffer(i*2+1,wbuffer[i].bufferColor,INDICATOR_COLOR_INDEX);
         PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_COLOR_LINE);
         PlotIndexSetInteger(i,PLOT_COLOR_INDEXES,2);
         PlotIndexSetInteger(i,PLOT_LINE_COLOR,0,inpColorUp);
         PlotIndexSetInteger(i,PLOT_LINE_COLOR,1,inpColorDn);
         PlotIndexSetInteger(i,PLOT_LINE_WIDTH,inpLinesWidth);
         PlotIndexSetInteger(i,PLOT_LINE_STYLE,inpLinesStyle);
         PlotIndexSetString(i,PLOT_LABEL,"Smoother ("+(string)((i+1)*_step)+")");
            iSmoother[i].init((i+1)*_step);
   }
   //      
   //--- indicator short name assignment
   //
         IndicatorSetString(INDICATOR_SHORTNAME,"Smoother rainbow, step ("+(string)_step+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      for (int k=0; k<20; k++)
      {
         wbuffer[k].buffer[i]      = iSmoother[k].calculate(_price,i,rates_total);
         wbuffer[k].bufferColor[i] = (i>0) ? (wbuffer[k].buffer[i]>wbuffer[k].buffer[i-1]) ? 0 : (wbuffer[k].buffer[i]<wbuffer[k].buffer[i-1]) ? 1 : wbuffer[k].bufferColor[i-1] : 0;
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
      
      double calculate(double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

         //
         //
         //
                    
         if (i>0)
         {
            m_array[i].l0 = (1.0-m_alpha)*value + m_alpha*m_array[i-1].l0;
            m_array[i].l1 = (value-m_array[i].l0)*(1-m_beta) + m_beta*m_array[i-1].l1;
            m_array[i].l2 =  m_array[i].l0 + m_array[i].l1;
            m_array[i].l3 = (m_array[i].l2 - m_array[i-1].l4)*(1.0-m_alpha)*(1.0-m_alpha) + m_alpha*m_alpha*m_array[i-1].l3;
            m_array[i].l4 =  m_array[i-1].l4 + m_array[i].l3;
         }                    
         else { m_array[i].l0 = m_array[i].l1 = m_array[i].l4 = value; m_array[i].l2 = m_array[i].l3 = 0; }
         return(m_array[i].l4);
      }
};
CSmoother iSmoother[20];
//------------------------------------------------------------------
