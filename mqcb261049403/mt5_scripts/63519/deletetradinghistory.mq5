//+------------------------------------------------------------------+
//|                                         DeleteTradingHistory.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2025, MetaQuotes Ltd."
#property link        "https://forge.mql5.io"
#property version     "1.00"
#property description "The script deletes all autotrading graphic objects from the current chart"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- Переменные
   bool res   = true;               // результат удаления
   int  num   = 0;                  // количество удалённых объектов
   int  total = ObjectsTotal(0, 0); // количество графических объектов в главном окне текущего чарта

//--- Цикл по графическим объектам
   for(int i = total-1; i >= 0; i--)
     {
      //--- получаем имя текущего объекта по индексу цикла
      string obj_name = ObjectName(0, i, 0);
      
      //--- при ошибке выбора, или если объект не принадлежит автоторговле - идём к следующему
      if(obj_name == "" || StringFind(obj_name, "autotrade #") != 0)
         continue;
      
      //--- если объект успешно удалён - увеличиваем счётчик удалённых объектов
      if(ObjectDelete(0, obj_name))
         num++;
      //--- иначе - взводим флаг ошибки
      else
         res = false;
     }

//--- Текст сообщения в зависимости от результата удаления графических объектов
   string message = (res ? StringFormat("Removal of %d autotrading objects from the \"%s\" chart was successful", num, Symbol()) :
                     StringFormat("There were errors when removing %d autotrading objects from the \"%s\" chart", num, Symbol()));

//--- Выводим сообщение и перерисовываем график
   Print(message);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
