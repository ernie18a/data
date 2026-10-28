#property copyright "Scriptong"
#property link      "http://advancetools.net"

#property strict

#include <WinUser32.mqh>
#import "user32.dll"
	int RegisterWindowMessageW(string lpString); 
#import


// Типы нестандартных графиков
enum ENUM_CONVERT_TYPE
{
   CONVERT_TYPE_TF,                                                                                // График нестандартного периода
   CONVERT_TYPE_POINT,                                                                             // График равновысоких свечей
   CONVERT_TYPE_VOLUME                                                                             // Эквиобъемный график
};

enum ENUM_BID_ASK_TYPE
{
   BID_ASK_TYPE_ONLY_BID,                                                                          // By Bid / По Bid   
   BID_ASK_TYPE_ONLY_ASK,                                                                          // By Ask / По Ask
   BID_ASK_TYPE_ONLY_BID_HIGH_ASK_LOW,                                                             // Close - max Bid, Open - min Ask
   BID_ASK_TYPE_ONLY_BID_LOW_ASK_HIGH                                                              // Close - max Ask, Open - min Bid   
};

struct TickStruct
{
   datetime time;
   double   bid;
   double   ask;  
   
   TickStruct(datetime dtTime = 0, double dBid = 0.0, double dAsk = 0.0)
   {
      time = dtTime;
      bid = dBid;
      ask = dAsk;
   } 
};

// Класс для обслуживания графиков нестандартного периода. Используется в индикаторе TicksCollector.
class NonStandartTFChart
{
   bool              m_isActive;                                                                   // Используется ли чарт?
   int               m_tfNameInMinutes;                                                            // Количество минут, выстыпающее идентификатором графика. Например, 313 - это EURUSD, M313
   int               m_chartProperty;                                                              // Свойство графика. Например, для эквиобъемного графика - количество тиков в свече, для графика..
                                                                                                   // ..равновысоких свечей - количество пунктов, для графика нестандартного периода - количество..
                                                                                                   // ..секунд в свече
   int               m_digits;                                                                     // Количество значащих цифр после запятой в значении котировки валюты
   int               m_ratesSize;                                                                  // Размер стуктуры MqlRates
   int               m_mt4Message;                                                                 // Дескриптор внутреннего сообщения терминала
   
   double            m_point;                                                                      // Точность представления котировки текущего символа
   
   string            m_symbol;                                                                     // Текуший символ
   
   ENUM_CONVERT_TYPE m_convertType;                                                                // Тип объекта
   ENUM_BID_ASK_TYPE m_bidAskType;                                                                 // Ценовой тип построения графика
   
   
   int               m_fileHandle;                                                                 // Описатель файла истории, с которым работает экземпляр класса
   int               m_hWindow;                                                                    // Дескриптор окна, с которым работает экземпляр класса
   
   MqlRates          m_rates;                                                                      // Данные о текущей свече

   
public:
                     NonStandartTFChart(bool isActive, int tfNameInMinutes, int chartProperty, ENUM_CONVERT_TYPE convertType, ENUM_BID_ASK_TYPE bidAskType, int digits, double point, string symbol);
                    ~NonStandartTFChart(void);
   bool              CreateHistoryFile(void);      
   void              CloseFile(void);       
   bool              ConvertData(const TickStruct &tick, bool doFlush);   
   void              SetPointerToEndOfFile(void) const;
   void              UpdateChart(void);  
                    
private:
   void              CreateNewRatesHighLow(const TickStruct &tick);
   void              CreateRatesHighLow(const TickStruct &tick);
   bool              IsNewBarByConvertType(datetime &time) const;
   bool              IsFindChart(void);
};


//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Конструктор                                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
NonStandartTFChart::NonStandartTFChart(bool isActive, int tfNameInMinutes, int chartProperty, ENUM_CONVERT_TYPE convertType, ENUM_BID_ASK_TYPE bidAskType, int digits, double point, string symbol) :        
                                                                                                       m_isActive(isActive)
                                                                                                      ,m_tfNameInMinutes(tfNameInMinutes)
                                                                                                      ,m_chartProperty(chartProperty)
                                                                                                      ,m_convertType(convertType)
                                                                                                      ,m_bidAskType(bidAskType)
                                                                                                      ,m_digits(digits)
                                                                                                      ,m_point(point)
                                                                                                      ,m_symbol(symbol)
                                                                                                      ,m_fileHandle(-1)
                                                                                                      ,m_hWindow(NULL)
{
   ZeroMemory(m_rates);
   m_ratesSize = sizeof(MqlRates);
   if (IsDllsAllowed())
      m_mt4Message = RegisterWindowMessageW("MetaTrader4_Internal_Message");
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Деструктор                                                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
NonStandartTFChart::~NonStandartTFChart(void)
{
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Создание файла истории                                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool NonStandartTFChart::CreateHistoryFile(void)
{
   if (!m_isActive)
      return true;

   // Открытие файла
   string fileName = m_symbol + IntegerToString(m_tfNameInMinutes) + ".hst";
   m_fileHandle = FileOpenHistory(fileName, FILE_BIN | FILE_WRITE | FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_ANSI);
   if (m_fileHandle < 0)
   {
      if (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian")
         Alert(WindowExpertName(), ": не удалось открыть файл ", fileName, ". Индикатор отключен.");
      else
         Alert(WindowExpertName(), ": unable to open the file ", fileName, ". Indicator is off.");
      
      m_isActive = false;
      return false;                                
   }
   
   // Запись заголовка
   string   copyright="(C)opyright 2003, MetaQuotes Software Corp.";
   int      unused[13] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

   FileWriteInteger(m_fileHandle, 401, LONG_VALUE);
   FileWriteString(m_fileHandle, copyright, 64);
   FileWriteString(m_fileHandle, m_symbol, 12);
   FileWriteInteger(m_fileHandle, m_tfNameInMinutes, LONG_VALUE);
   FileWriteInteger(m_fileHandle, m_digits, LONG_VALUE);
   FileWriteInteger(m_fileHandle, 0, LONG_VALUE);
   FileWriteInteger(m_fileHandle, 0, LONG_VALUE);
   FileWriteArray(m_fileHandle, unused, 0, 13);

   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Закрытие файла истории                                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void NonStandartTFChart::CloseFile(void)
{
   if (!m_isActive)
      return;
      
   if (m_fileHandle < 0)
      return;
      
   FileClose(m_fileHandle);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Преобразование данных для отображения на графике нестандартного периода                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool NonStandartTFChart::ConvertData(const TickStruct &tick, bool doFlush)
{
   if (!m_isActive)
      return true;

   // Обновление данных текущего бара
   double price = (m_bidAskType == BID_ASK_TYPE_ONLY_ASK || m_bidAskType == BID_ASK_TYPE_ONLY_BID_LOW_ASK_HIGH)? tick.ask : tick.bid;
   CreateRatesHighLow(tick);
   m_rates.tick_volume++;

   // Формирование нового бара
   datetime time = tick.time;
   if (m_rates.time == 0 || IsNewBarByConvertType(time))
   {
      CreateNewRatesHighLow(tick);
      if ((int)(time - m_rates.time) < 60)                                                         // Время открытия нового бара отличается от времени открытия предыдущего бара менее, чем на 1-у минуту
         time = m_rates.time + 60;                                                                 // Сдвиг времени открытия нового бара на одну минуту вперед
      m_rates.time = time;
   }
   // Продолжение формирования бара
   else
      FileSeek(m_fileHandle, -m_ratesSize, SEEK_CUR);
   
   // Запись данных текущего бара
   if (FileWriteStruct(m_fileHandle, m_rates) != m_ratesSize)
   {
      if (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian")
         Alert(WindowExpertName(), ": ошибка при записи в файл истории. Индикатор отключен.");
      else
         Alert(WindowExpertName(), ": unable to write to the history file. Indicator is off.");
      return false;
   }
   
   if (doFlush)
      FileFlush(m_fileHandle);
      
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Определение формирования нового бара по условиям типа текущего экземпляра класса                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool NonStandartTFChart::IsNewBarByConvertType(datetime &time) const
{
   switch (m_convertType)
   {
      case CONVERT_TYPE_TF:      if (time < m_rates.time + m_chartProperty)
                                    return false;
                                    
                                 time = time / m_chartProperty * m_chartProperty;
                                 return true;
                                 
      case CONVERT_TYPE_POINT:   return m_rates.high - m_rates.low - m_chartProperty * m_point > m_point * 0.9;
      case CONVERT_TYPE_VOLUME:  return m_rates.tick_volume > m_chartProperty;
   }
   
   return false;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Формирование новой свечи в соответствии с выбранным ценовым типом                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void NonStandartTFChart::CreateNewRatesHighLow(const TickStruct &tick)
{
   switch(m_bidAskType)
   {
      case BID_ASK_TYPE_ONLY_BID:                  m_rates.open = tick.bid;
                                                   m_rates.close = tick.bid;
                                                   m_rates.high = tick.bid;
                                                   m_rates.low = tick.bid;
                                                   m_rates.tick_volume = 1;
                                                   break;

      case BID_ASK_TYPE_ONLY_ASK:                  m_rates.open = tick.ask;
                                                   m_rates.close = tick.ask;
                                                   m_rates.high = tick.ask;
                                                   m_rates.low = tick.ask;
                                                   m_rates.tick_volume = 1;
                                                   break;

      case BID_ASK_TYPE_ONLY_BID_HIGH_ASK_LOW:     m_rates.open = tick.ask;
                                                   m_rates.close = tick.bid;
                                                   m_rates.high = MathMax(m_rates.close, m_rates.open);
                                                   m_rates.low = MathMin(m_rates.close, m_rates.open);
                                                   m_rates.tick_volume = 2;
                                                   break;

      case BID_ASK_TYPE_ONLY_BID_LOW_ASK_HIGH:     m_rates.open = tick.bid;
                                                   m_rates.close = tick.ask;
                                                   m_rates.high = MathMax(m_rates.close, m_rates.open);
                                                   m_rates.low = MathMin(m_rates.close, m_rates.open);
                                                   m_rates.tick_volume = 2;
                                                   break;
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Распределение Bid и Ask по свече в соответствии с выбранным ценовым типом                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void NonStandartTFChart::CreateRatesHighLow(const TickStruct &tick)
{
   switch(m_bidAskType)
   {
      case BID_ASK_TYPE_ONLY_BID:                  m_rates.high = MathMax(m_rates.high, tick.bid);
                                                   m_rates.low = MathMin(m_rates.low, tick.bid);
                                                   m_rates.close = tick.bid;
                                                   break;

      case BID_ASK_TYPE_ONLY_ASK:                  m_rates.high = MathMax(m_rates.high, tick.ask);
                                                   m_rates.low = MathMin(m_rates.low, tick.ask);
                                                   m_rates.close = tick.ask;
                                                   break;

      case BID_ASK_TYPE_ONLY_BID_HIGH_ASK_LOW:     m_rates.open = MathMin(m_rates.open, tick.ask);
                                                   m_rates.close = MathMax(m_rates.close, tick.bid);
                                                   m_rates.high = MathMax(m_rates.close, m_rates.open);
                                                   m_rates.low = MathMin(m_rates.close, m_rates.open);
                                                   break;

      case BID_ASK_TYPE_ONLY_BID_LOW_ASK_HIGH:     m_rates.open = MathMin(m_rates.open, tick.bid);
                                                   m_rates.close = MathMax(m_rates.close, tick.ask);
                                                   m_rates.high = MathMax(m_rates.close, m_rates.open);
                                                   m_rates.low = MathMin(m_rates.close, m_rates.open);
                                                   break;
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Обновление графика, соответствующего экземпляру объекта                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void NonStandartTFChart::UpdateChart(void)
{
   if (!IsFindChart())
      return;

   PostMessageW(m_hWindow, WM_COMMAND, 33324, 0);
   if (m_mt4Message > 0)
      SendMessageW(m_hWindow, m_mt4Message, 2, 1);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Поиск окна графика по символу и периоду                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool NonStandartTFChart::IsFindChart(void)
{
   if (m_hWindow > 0)
      return true;
      
   m_hWindow = WindowHandle(m_symbol, m_tfNameInMinutes);
   if (m_hWindow <= 0)
      return false;
      
   Print("Chart window detected: ", m_symbol, ", M", m_tfNameInMinutes);
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Установка указателя чтения/записи файла на конец файла                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void NonStandartTFChart::SetPointerToEndOfFile(void) const
{
   if (!m_isActive)
      return;
      
   if (m_fileHandle < 0)
      return;
      
   FileFlush(m_fileHandle);   
   FileSeek(m_fileHandle, 0, SEEK_END);
}


