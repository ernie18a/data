//+------------------------------------------------------------------+
//|                                           CHART_BRING_TO_TOP.mq5 |
//|                              Copyright © 2014, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.02"
#property description "The script switches all open charts after a certain interval."
//--- покажем окно входных параметров при запуске скрипта
//--- show window of input parameters when you run the script
#property script_show_inputs
//--- входные параметры скрипта
//--- the script input parameters
input int      milliseconds=3000;      // интервал // interval
input string   name_symbol="RTS-9.16"; // активировать только // activate only
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
// variables for chart ID
   long currChart,prevChart=ChartFirst();
//--- обрабатываем первый график // process the first graph
   if(name_symbol!="")
     {
      if(ChartSymbol(prevChart)==name_symbol)
        {
         // Print(i," ",ChartSymbol(currChart)," ID =",currChart);
         ChartBringToTop(prevChart);
         Sleep((int)MathAbs(milliseconds));
        }
     }
   else
     {
      // Print(i," ",ChartSymbol(currChart)," ID =",currChart);
      ChartBringToTop(prevChart);
      Sleep((int)MathAbs(milliseconds));
     }
//---
   int i=0,limit=100;
//   Print("ChartFirst = ",ChartSymbol(prevChart)," ID = ",prevChart);
// У нас наверняка не больше 100 открытых графиков
// We have certainly not more than 100 open charts
   while(i<limit)// 
     {
      // На основании предыдущего получим новый график
      // Get the new chart ID by using the previous chart ID
      currChart=ChartNext(prevChart);
      if(currChart<0) break;  // достигли конца списка графиков // Have reached the end of the chart list
      if(name_symbol!="")
        {
         if(ChartSymbol(currChart)==name_symbol)
           {
            // Print(i," ",ChartSymbol(currChart)," ID =",currChart);
            ChartBringToTop(currChart);
            Sleep((int)MathAbs(milliseconds));
           }
        }
      else
        {
         // Print(i," ",ChartSymbol(currChart)," ID =",currChart);
         ChartBringToTop(prevChart);
         Sleep((int)MathAbs(milliseconds));
        }
      // Запомним идентификатор текущего графика для ChartNext()
      // Let's save the current chart ID for the ChartNext()
      prevChart=currChart;
      // Не забудем увеличить счетчик
      // Do not forget to increase the counter
      i++;
     }
  }
//+------------------------------------------------------------------+
//| Отправка терминалу команды на показ графика поверх всех других.  |
//| Sends command to the terminal to display the chart above all others  |
//+------------------------------------------------------------------+
bool ChartBringToTop(const long chart_ID=0)
  {
//--- сбросим значение ошибки
   ResetLastError();
//--- покажем график поверх всех других
   if(!ChartSetInteger(chart_ID,CHART_BRING_TO_TOP,0,true))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
   ChartRedraw(chart_ID);
//--- успешное выполнение
   return(true);
  }
//+------------------------------------------------------------------+
