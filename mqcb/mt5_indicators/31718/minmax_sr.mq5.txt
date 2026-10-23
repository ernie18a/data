//------------------------------------------------------------------
#property copyright "© mladen, 2020"
#property link      "mladenfx@gmail.com"
#define _minMaxSteps 10
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers _minMaxSteps
#property indicator_plots   _minMaxSteps
//------------------------------------------------------------------ 
//
//
//

input int             inpStartFrom  = 10;          // Start from
input int             inpStep       = 5;           // Step size
input ENUM_LINE_STYLE inpLineStyle  = STYLE_DOT;   // Lines style
input color           inpStartColor = clrGreen;    // Start color
input color           inpEndColor   = clrDeepPink; // End color

//
//
//

struct sSimpleBuffer
{
   double buffer[];
   int    period;
};
sSimpleBuffer buffers[_minMaxSteps];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   int _startFrom = (inpStartFrom>0) ? inpStartFrom : 1;
   int _stepSize  = (inpStep>0) ? inpStep : 1;
   for (int i=0; i<_minMaxSteps; i++)
   {
      SetIndexBuffer(i,buffers[i].buffer,INDICATOR_DATA);
         PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_LINE);
         PlotIndexSetInteger(i,PLOT_LINE_STYLE,i<_minMaxSteps-1 ? inpLineStyle :STYLE_SOLID);
         PlotIndexSetInteger(i,PLOT_LINE_COLOR,gradientColor(i,_minMaxSteps+1,inpStartColor,inpEndColor));
         
               //
               //
               //
               
               buffers[i].period = _startFrom+i*_stepSize;
   }
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

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
   int limit = prev_calculated-1; if (limit<0) limit = 0;         

   //
   //
   //

      struct sWorkStruct
      {
         double min[_minMaxSteps];
         double max[_minMaxSteps];
      };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize <rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
                     
   //
   //
   //
                        
   for (int i=limit; i<rates_total; i++)
   {
      for (int k=0; k<_minMaxSteps; k++)
      {
         int _period = buffers[k].period;
         int _start  = i-_period; if (_start < 0) { _start =0; _period = i+1; }
            m_work[i].min[k] = close[ArrayMinimum(close,_start,_period)];
            m_work[i].max[k] = close[ArrayMaximum(close,_start,_period)];
            
            //
            //
            //
         
            buffers[k].buffer[i] = (m_work[i].max[k]+m_work[i].min[k])/2.0;
      }
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

color getColor(int stepNo, int totalSteps, color from, color to)
{
   double stes = (double)totalSteps-1.0;
   double step = (from-to)/(stes);
   return((color)round(from-step*stepNo));
}

color gradientColor(int step, int totalSteps, color from, color to)
{
   color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
}