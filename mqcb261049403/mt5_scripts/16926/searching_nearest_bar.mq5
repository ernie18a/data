//+------------------------------------------------------------------+
//|                                        Searching Nearest Bar.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- возвращает временную координату, соответствующую точке, в которой брошен мышкой данный эксперт или скрипт
   datetime t=ChartTimeOnDropped();
//--- объявление переменной для найденного времени
   datetime found_t=0;
   int bar=SearchingNearestBar(Symbol(),Period(),t,found_t);
   if(bar!=-1)
      Print("Бар номер ",bar,", время бара ",found_t);
  }
//+------------------------------------------------------------------+
//| Поиск ближайшего бара                                            |
//+------------------------------------------------------------------+
int SearchingNearestBar(string symbol,
                        ENUM_TIMEFRAMES time_frame,
                        datetime find_time,
                        datetime &found_time)
  {
//+------------------------------------------------------------------+
//| symbol - символ                                                  |
//| time_frame - период                                              |
//| find_time - искомое время                                        |
//| found_time - время открытия ближайшего бара                      |
//| если функция возвратила "-1", значит переменная "found_time"     |
//|     содержит неопределёное значение                              |
//+------------------------------------------------------------------+
   if(find_time<0)
      return(-1);
   datetime arr_time[];
   datetime time_left=0;
   datetime time_right=0;
//--- обращение по начальной позиции "0" и количеству требуемых элементов "1"
   CopyTime(symbol,time_frame,0,1,arr_time);
//--- получаем время открытия бара "0" (самого правого бара на графике)
   datetime time0=arr_time[0];
//--- освобождаем буфер динамического массива "arr_time" и устанавливаем размер нулевого измерения в 0
   ArrayFree(arr_time);
//--- обращение по начальной дате "find_time" и количеству требуемых элементов "1"
   if(CopyTime(symbol,time_frame,find_time,1,arr_time)>0)
     {
      time_left=arr_time[0];
      //--- если time0==time_left, значит искомое время находится правее бара с индексом "0"
      if(time0==time_left)
        {
         found_time=time0;
         return(0);
        }
      else
         ArrayFree(arr_time); // освобождаем буфер динамического массива "arr_time" и устанавливаем размер нулевого измерения в 0
      //--- обращение по начальной "time_left" и конечной "time0" датам требуемого интервала времени
      int count=CopyTime(symbol,time_frame,time_left,time0,arr_time);
      if(count>0)
        {
         //--- в массиве arr_time[] элемент с индексом "0", на графике, будет левее элемента "count-1"
         //Print("между ",time_left," и ",time0," ",count," баров. Бар [",0,"] ",arr_time[0]);
         time_left=arr_time[0];
         time_right=arr_time[1];
         //--- объяснение, какие бары имееют какое время
         //Print("левый бар имеет время ",time_left,", искомое время ",find_time,", правый бар имеет время ",time_right);
         //--- среднее время между time_left и time_right
         datetime middle_time=(time_left+time_right)/2;
         if(find_time<middle_time)
           {
            //--- обращение по начальной "time_left" и конечной "time0" датам требуемого интервала времени
            int count_bar=CopyTime(symbol,time_frame,time_left,time0,arr_time);
            if(count_bar!=-1)
              {
               //Print(time_left);
               found_time=time_left;
               return (count_bar-1);
              }
           }
         else
           {
            //--- обращение по начальной "time_right" и конечной "time0" датам требуемого интервала времени
            int count_bar=CopyTime(symbol,time_frame,time_right,time0,arr_time);
            if(count_bar!=-1)
              {
               //Print(time_right);
               found_time=time_right;
               return (count_bar-1);
              }
           }
        }
      else
         return(-1);
     }
   return(-1);
  }
//+------------------------------------------------------------------+
