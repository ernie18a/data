//+------------------------------------------------------------------+
//|                                                     IsNewBar.mqh |
//|                               Copyright © 2011, Nikolay Kositsin |
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "2011,   Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"
//+------------------------------------------------------------------+
//|  Алгоритм определения момента появления нового бара              |
//+------------------------------------------------------------------+  
class CIsNewBar
  {
   //----
public:
   //---- функция определения момента появления нового бара
   bool IsNewBar(string symbol,ENUM_TIMEFRAMES timeframe)
     {
      //---- получим время появления текущего бара
      datetime TNew=datetime(SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE));

      if(TNew!=m_TOld && TNew) // проверка на появление нового бара
        {
         m_TOld=TNew;
         return(true); // появился новый бар!
        }
      //----
      return(false); // новых баров пока нет!
     };

   //---- конструктор класса    
                     CIsNewBar(){m_TOld=-1;};

protected: datetime m_TOld;
   //---- 
  };
//+------------------------------------------------------------------+
