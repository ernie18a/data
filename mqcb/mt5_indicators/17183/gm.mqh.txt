//+------------------------------------------------------------------+
//|                                                           GM.mqh |
//|                                           Copyright 2016, DC2008 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, DC2008"
#property link      "https://www.mql5.com/ru/users/dc2008"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Класс для работы с графической памятью                           |
//+------------------------------------------------------------------+
class CGM
  {
private:
public:
   string            m_name;        // имя графического объекта
                     CGM(){}
                    ~CGM(){}
   void              Create(string name) {m_name=name;}
   // чтение свойства OBJPROP_PRICE
   double            R_OBJPROP_PRICE(int prop_modifier=0)
     {
      return(ObjectGetDouble(0,m_name,OBJPROP_PRICE,prop_modifier));
     }
   // чтение свойства OBJPROP_TIME
   datetime          R_OBJPROP_TIME(int prop_modifier=0)
     {
      return((datetime)ObjectGetInteger(0,m_name,OBJPROP_TIME,prop_modifier));
     }
   // чтение свойства OBJPROP_ANGLE
   double            R_OBJPROP_ANGLE()
     {
      return(ObjectGetDouble(0,m_name,OBJPROP_ANGLE));
     }
   // чтение свойства OBJPROP_TEXT
   string            R_OBJPROP_TEXT()
     {
      return(ObjectGetString(0,m_name,OBJPROP_TEXT));
     }
   // возвращает значение цены для указанного времени
   double            R_ValueByTime(datetime time)
     {
      return(ObjectGetValueByTime(0,m_name,time));
     }
   // запись свойства OBJPROP_TEXT
   void              W_OBJPROP_TEXT(string text)
     {
      ObjectSetString(0,m_name,OBJPROP_TEXT,text);
     }
  };
