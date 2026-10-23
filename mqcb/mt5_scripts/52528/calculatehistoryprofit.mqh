//+-------------------------------------------------------------------+
//|                                           CalculateHistoryProfit  |
//|                         Version 1.0                               |
//|                                                                   |
//| Script for copying and logging position data                      |
//| and calculating profit over a specified period.                   |
//|                                                                   |
//| Features:                                                         |
//|  - Includes a graphical panel loaded from an external library     |
//|    (MtGuiController.dll) for selecting dates, symbols, and magics.|
//|  - Profit and deal count calculation based on selected criteria   |
//|    such as date range, magic numbers, and symbols.                |
//|                                                                   |
//|  Last changes:                                                    |
//|    v1.0:                                                          |
//|  - Initial release                                                |
//|                                                                   |
//+-------------------------------------------------------------------+

#property version     "1.0"
#property copyright   "Snail000"
#property link        "https://github.com/5nail000/MtGui_ProfitCalculator"
#property description "Script for calculating profit over a period using a graphical interface"
// #property script_show_inputs

//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#import "MtGuiController.dll"

//+------------------------------------------------------------------+
//| Global variables for handling panel and calculations             |
//+------------------------------------------------------------------+
datetime start_date, end_date;
string current_magics, current_symbols;
int magic_number = 0;
double total_profit = 0;
int total_deals = 0;
MqlDateTime current_time; // Структура для хранения текущего времени

//+------------------------------------------------------------------+
//| Class to handle account-related data and calculations            |
//+------------------------------------------------------------------+
class CAccountInfo
{
protected:

public:
    datetime date_today_start, date_week_start, date_month_start, date_year_start, date_month_end, date_year_end;
    int magic_number;
    double total_profit;
    int total_deals;
    MqlDateTime current_time;

    CAccountInfo(void)
    {
        // Initialize variables
        magic_number = 0;
        total_profit = 0.0;
        total_deals = 0;
    }
    ~CAccountInfo(void) {}

    //+------------------------------------------------------------------+
    //| Initialization of default values and GUI setup                  |
    //+------------------------------------------------------------------+
    bool Init(void)
    {
        // Get current time and set start/end dates
        TimeToStruct(TimeCurrent(), current_time);
        date_today_start = StringToTime(StringFormat("%d.%02d.%02d 00:00:00", current_time.year, current_time.mon, current_time.day));
        date_week_start = GetWeekStart();
        date_month_start = StringToTime(StringFormat("%d.%02d.01 00:00:00", current_time.year, current_time.mon));
        date_year_start = StringToTime(StringFormat("%d.01.01 00:00:00", current_time.year));
        date_month_end = StringToTime(StringFormat("%d.%02d.%02d 23:59:59", current_time.year, current_time.mon, DaysInMonth(current_time.mon, current_time.year)));
        date_year_end = StringToTime(StringFormat("%d.12.31 23:59:59", current_time.year));
        
        // Initialize start and end dates for calculations
        start_date = date_month_start;
        end_date = date_year_end;
        
        // Create the GUI timer and load graphical interface
        EventSetMillisecondTimer(200);
        GuiController::ShowForm("Form1");
        GuiController::SendEvent("Picker_DateStart", 14, (int)start_date, 0.0, "");
        GuiController::SendEvent("Picker_DateEnd", 14, (int)end_date, 0.0, "");
        Render_ListBoxes(start_date, end_date);
        Print("Calculator is ON");

        return true;
    }

    //+------------------------------------------------------------------+
    //| Deinitialization: cleanup after script stops                     |
    //+------------------------------------------------------------------+
    void Deinit(void)
    {
      GuiController::HideForm("Form1");
      EventKillTimer();
      Print("Calculator is OFF");
    }

    //+------------------------------------------------------------------+
    //| Main processing function to handle GUI events and calculations   |
    //+------------------------------------------------------------------+
    void Processing(void)
    {
        // Loop through all GUI events
        for(static int i = 0; i < GuiController::EventsTotal(); i++)
        {
            int id;
            string el_name;
            long lparam;
            double dparam;
            string sparam;
            GuiController::GetEvent(i, el_name, id, lparam, dparam, sparam);
            // Print("i: ", i);
            // Print("id: ", id);
            // Print("el_name: ", el_name);
            // Print("lparam: ", lparam);
            // Print("dparam: ", dparam);
            // Print("sparam: ", sparam);
            
            // Handle events related to date pickers
            if(el_name == "Picker_DateStart"){
               start_date = (datetime)lparam;
               Render_ListBoxes(start_date, end_date);
            }
            if(el_name == "Picker_DateEnd"){
               end_date = (datetime)lparam;
               Render_ListBoxes(start_date, end_date);
            }

            // Handle selections for magic numbers and symbols
            if(el_name == "listBox_magics"){
               current_magics = (StringFind(sparam, "ALL") != -1) ? "ALL" : sparam;
               //if (StringFind(current_magics, "Empty") != -1){
               //   int comma_index = StringFind(current_magics, ",");
               //   string second_part = (comma_index != -1) ? StringSubstr(current_magics, comma_index + 1) : "";
               //   current_magics = (comma_index != -1) ? "0," + second_part : "0";
               //}
            }
            if(el_name == "listBox_symbols"){
               current_symbols = (StringFind(sparam, "ALL") != -1) ? "ALL" : sparam;
            }
            
            // Handle button clicks for preset date ranges
            if(el_name == "b_today"){
               start_date = date_today_start;
               GuiController::SendEvent("Picker_DateStart", 14, (int)date_today_start, 0.0, "");
               Render_ListBoxes(start_date, end_date);
            }
            if(el_name == "b_week"){
               start_date = date_week_start;
               GuiController::SendEvent("Picker_DateStart", 14, (int)date_week_start, 0.0, "");
               Render_ListBoxes(start_date, end_date);
            }
            if(el_name == "b_month"){
               start_date = date_month_start;
               GuiController::SendEvent("Picker_DateStart", 14, (int)date_month_start, 0.0, "");
               Render_ListBoxes(start_date, end_date);
            }
            if(el_name == "b_year"){
               start_date = date_year_start;
               GuiController::SendEvent("Picker_DateStart", 14, (int)date_year_start, 0.0, "");
               Render_ListBoxes(start_date, end_date);
            }
            
            // Handle submit button to calculate profit
            if(el_name == "button_submit"){
               Print("Calculating");
               CalculateProfit();
               GuiController::SendEvent("label_profit", 3, 0, 0.0, StringFormat("$%.2f", total_profit));
               GuiController::SendEvent("label_deals", 3, 0, 0.0, StringFormat("%d", total_deals));
               GuiController::SendEvent("textBox1", 3, 0, 0.0, StringFormat("%s - %s\r\n\r\nMagics: %s\r\n\r\nSymbols: %s", TimeToString(start_date, TIME_DATE), TimeToString(end_date, TIME_DATE), current_magics, current_symbols));
            }
            
            // Handle shutdown checkbox
            if(el_name == "check_shutdown") ExpertRemove();
        }
        
        ChartRedraw();
        Sleep(500);
    }

private:

    //+------------------------------------------------------------------+
    //| Render ListBoxes for magic numbers and symbols                   |
    //+------------------------------------------------------------------+
    void Render_ListBoxes(datetime start, datetime end){
        string magicNumbers = "ALL,Empty," + GetUniqueMagicNumbers(start, end);
        string uniqueSymbols = "ALL," + GetUniqueSymbols(start, end);
        GuiController::SendEvent("listBox_magics", 16, 0, 0.0, magicNumbers);
        GuiController::SendEvent("listBox_symbols", 16, 0, 0.0, uniqueSymbols);
        GuiController::SendEvent("listBox_magics", 18, 0, 0.0, "0");
        GuiController::SendEvent("listBox_symbols", 18, 0, 0.0, "0");
    }

    //+------------------------------------------------------------------+
    //| Calculate total profit and deal count for the selected period    |
    //+------------------------------------------------------------------+
    void CalculateProfit()
    {
       total_profit = 0;
       total_deals = 0;
       
       HistorySelect(0, TimeCurrent());
       int total_orders = HistoryDealsTotal();
   
       for (int i = total_orders - 1; i >= 0; i--)
       {
           ulong deal_ticket = HistoryDealGetTicket(i);
           datetime deal_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
           if (HistoryDealGetInteger(deal_ticket, DEAL_ENTRY) != 1) continue;
   
           if (deal_time >= start_date && deal_time <= end_date)
           {
               string deal_symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
               int deal_magic = (int)HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
               int deal_type = (int)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
               
               // Фильтрация по типу сделки (покупка или продажа)
               bool type_filter = (deal_type == 0 || deal_type == 1);
   
               // Фильтрация по символам
               bool symbol_filter = (StringFind(current_symbols, "ALL") != -1) || (StringFind(current_symbols, deal_symbol) != -1);
   
               // Фильтрация по магикам
               bool magic_filter_all = (StringFind(current_magics, "ALL") != -1);
               
               // Разделение строки с магиками на массив
               string magic_values[];
               int count = StringSplit(current_magics, ',', magic_values);
   
               // Проверка на "Empty" и магик 0
               bool magic_filter_empty = false;
               for (int j = 0; j < count; j++)
               {
                   if (magic_values[j] == "Empty" && deal_magic == 0)
                   {
                       magic_filter_empty = true;
                       break;
                   }
               }
   
               // Проверка на конкретный магик
               bool magic_filter_exact = false;
               for (int j = 0; j < count; j++)
               {
                   if (IntegerToString(deal_magic) == magic_values[j])
                   {
                       magic_filter_exact = true;
                       break;
                   }
               }
   
               // Если магики "ALL" или "Empty" или найден точный магик
               if (type_filter && symbol_filter && (magic_filter_all || magic_filter_empty || magic_filter_exact))
               {
                   double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
                   double deal_commission = HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
                   double deal_swap = HistoryDealGetDouble(deal_ticket, DEAL_SWAP);
   
                   total_profit += deal_profit + deal_commission + deal_swap;
                   total_deals++;
                   ShowTicket(deal_ticket);
               }
           }
       }
    }

   //+------------------------------------------------------------------+
   //| Function to get the number of days in a month                    |
   //+------------------------------------------------------------------+
   int DaysInMonth(int month, int year)
   {
      switch(month)
      {
         case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31;
         case 4: case 6: case 9: case 11:
            return 30;
         case 2:
            // Проверка на високосный год
            if((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
               return 29;
            else
               return 28;
         default:
            return 30;
      }
   }
   
    //+------------------------------------------------------------------+
    //| Helper function to get unique magic numbers from deal history    |
    //+------------------------------------------------------------------+
   string GetUniqueMagicNumbers(datetime startDate, datetime endDate) {
       string magicNumbers = "";
       ulong magicSet[]; // Массив для хранения уникальных магических номеров
   
       // Выбор истории сделок за указанный диапазон дат
       if (!HistorySelect(startDate, endDate)) {
           return "";
       }
   
       int totalDeals = HistoryDealsTotal(); // Общее количество сделок в истории
   
       // Перебор всех сделок в истории по индексу
       for (int i = 0; i < totalDeals; i++) {
           ulong dealTicket = HistoryDealGetTicket(i); // Получаем тикет сделки по индексу
           if (dealTicket == 0) continue; // Пропускаем итерацию, если тикет нулевой
   
           // Получаем время завершения сделки напрямую по тикету
           datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
   
           // Проверяем, попадает ли время сделки в указанный диапазон
           if (dealTime >= startDate && dealTime <= endDate) {
               ulong magic = (ulong)HistoryDealGetInteger(dealTicket, DEAL_MAGIC); // Получаем магический номер сделки
               if (magic == 0) continue; // Пропускаем итерацию, если магический номер нулевой
   
               // Проверяем, есть ли уже этот магический номер в массиве
               if (ArrayFind(magicSet, magic) == -1) {
                   // Если нет, добавляем его в массив
                   ArrayResize(magicSet, ArraySize(magicSet) + 1);
                   magicSet[ArraySize(magicSet) - 1] = magic;
               }
           }
       }
   
       // Формируем строку с уникальными магическими номерами
       for (int j = 0; j < ArraySize(magicSet); j++) {
           magicNumbers += IntegerToString(magicSet[j]);
           if (j < ArraySize(magicSet) - 1) {
               magicNumbers += ","; // Добавляем запятую между номерами
           }
       }
       
       return SortNumbersAndWords(magicNumbers); // Возвращаем строку с уникальными магическими номерами
   }
   
    //+------------------------------------------------------------------+
    //| Helper function to get unique symbols from deal history          |
    //+------------------------------------------------------------------+
   string GetUniqueSymbols(datetime startDate, datetime endDate) {
       string symbols = "";
       string symbolSet[]; // Массив для хранения уникальных символов
   
       // Выбор истории сделок за указанный диапазон дат
       if (!HistorySelect(startDate, endDate)) {
           Print("Ошибка выбора истории сделок");
           return "";
       }
   
       int totalDeals = HistoryDealsTotal(); // Общее количество сделок в истории
       // Print("totalDeals: ", totalDeals);
   
       // Перебор всех сделок в истории
       for (int i = 0; i < totalDeals; i++) {
           ulong dealTicket = HistoryDealGetTicket(i); // Получаем тикет сделки по индексу
           if (dealTicket != 0) {
               // Получаем символ сделки
               string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
               if (dealSymbol == "") continue;
   
               // Проверяем, есть ли уже этот символ в массиве
               bool isSymbolExists = false;
               for (int j = 0; j < ArraySize(symbolSet); j++) {
                   if (symbolSet[j] == dealSymbol) {
                       isSymbolExists = true;
                       break;
                   }
               }
   
               // Если символ ещё не добавлен, добавляем его
               if (!isSymbolExists) {
                   ArrayResize(symbolSet, ArraySize(symbolSet) + 1);
                   symbolSet[ArraySize(symbolSet) - 1] = dealSymbol;
               }
           }
       }
       
       // Формируем строку с уникальными символами
       for (int j = 0; j < ArraySize(symbolSet); j++) {
           symbols += symbolSet[j];
           if (j < ArraySize(symbolSet) - 1) {
               symbols += ","; // Добавляем запятую между символами
           }
       }
   
       // Print("unique_symbols: ", symbols);
       return SortNumbersAndWords(symbols); // Возвращаем строку с уникальными магическими номерами
   }
   
   //+------------------------------------------------+
   //| Checking if an element is in an array          |
   //+------------------------------------------------+
   int ArrayFind(ulong &array[], ulong value) {
       for (int i = 0; i < ArraySize(array); i++) {
           if (array[i] == value) {
               return i; // Возвращаем индекс, если найдено
           }
       }
       return -1; // Если не найдено, возвращаем -1
   }
   
   //+-----------------------------------------------------------------------------------+
   //| Sorts the string by numbers in ascending order and words in alphabetical order    |
   //+-----------------------------------------------------------------------------------+
   string SortNumbersAndWords(string input_text) {
       // Разделяем строку на массив строк по запятой
       string elementsArray[]; 
       StringSplit(input_text, ',', elementsArray);
   
       // Массивы для чисел и слов
       int numbers[];
       string words[];
   
       // Разделяем элементы на числа и слова
       for (int i = 0; i < ArraySize(elementsArray); i++) {
           string element = elementsArray[i];
           if (IsStringDigit(element)) {
               // Если элемент является числом, преобразуем его в int и добавляем в массив чисел
               ArrayResize(numbers, ArraySize(numbers) + 1);
               numbers[ArraySize(numbers) - 1] = (int)StringToInteger(element);
           } else {
               // Если это слово, добавляем его в массив слов
               ArrayResize(words, ArraySize(words) + 1);
               words[ArraySize(words) - 1] = element;
           }
       }
   
       // Сортируем массивы чисел и слов
       ArraySort(numbers); // Сортировка чисел по возрастанию
       StringArraySort(words); // Сортировка слов по алфавиту
   
       // Собираем обратно в строку с чередованием
       string sortedElements = "";
       int numIndex = 0, wordIndex = 0;
   
       for (int i = 0; i < ArraySize(elementsArray); i++) {
           if (IsStringDigit(elementsArray[i])) {
               sortedElements += IntegerToString(numbers[numIndex]);
               numIndex++;
           } else {
               sortedElements += words[wordIndex];
               wordIndex++;
           }
   
           // Добавляем запятую между элементами
           if (i < ArraySize(elementsArray) - 1) {
               sortedElements += ",";
           }
       }
   
       return sortedElements;
   }
   
   // Вспомогательная функция для проверки, является ли строка числом
   bool IsStringDigit(string str) {
       for (int i = 0; i < StringLen(str); i++) {
           // Извлекаем символ как строку длиной 1 и проверяем, является ли он цифрой
           string character = StringSubstr(str, i, 1);
           if (character < "0" || character > "9") {
               return false; // Если хотя бы один символ не цифра, возвращаем false
           }
       }
       return true; // Все символы — цифры
   }
   
   // Функция для сортировки строк
   void StringArraySort(string &arr[]) {
       int n = ArraySize(arr);
       for (int i = 0; i < n - 1; i++) {
           for (int j = 0; j < n - i - 1; j++) {
               if (StringCompare(arr[j], arr[j + 1]) > 0) {
                   // Меняем местами строки
                   string temp = arr[j];
                   arr[j] = arr[j + 1];
                   arr[j + 1] = temp;
               }
           }
       }
   }
   
   
    //+------------------------------------------------------------------+
    //| Function to get the start of the current week                    |
    //+------------------------------------------------------------------+
   datetime GetWeekStart()
   {
       MqlDateTime dt;
       datetime c_time = TimeCurrent();
       TimeToStruct(c_time, dt);
       int day_of_week = dt.day_of_week; // 0 = воскресенье, 1 = понедельник, ..., 6 = суббота
       int days_to_subtract = (day_of_week == 0) ? 6 : day_of_week - 1; // Переводим воскресенье в 6 дней до понедельника
       datetime week_start = c_time - days_to_subtract * 86400; // 86400 секунд в сутках
       TimeToStruct(week_start, dt);
       return StringToTime(StringFormat("%d.%02d.%02d 00:00:00", dt.year, dt.mon, dt.day));
   }
   
   
   
   //+------------------------------------------------------------------+
   //| Function to display details of the deal                          |
   //+------------------------------------------------------------------+
   void ShowTicket(ulong deal_ticket)
   {
       double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
       datetime transaction_time = (datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME);
       int order_ticket = (int)HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
       int deal_type = (int)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
       string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
       int position_ID = (int)HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
       int deal_magic = (int)HistoryDealGetInteger(deal_ticket, DEAL_MAGIC);
   
       // Определяем описание сделки
       string descr;
       switch (deal_type)
       {
           case DEAL_TYPE_BALANCE:                  descr = "balance"; break;
           case DEAL_TYPE_CREDIT:                   descr = "credit"; break;
           case DEAL_TYPE_CHARGE:                   descr = "charge"; break;
           case DEAL_TYPE_CORRECTION:               descr = "correction"; break;
           case DEAL_TYPE_BUY:                      descr = "buy"; break;
           case DEAL_TYPE_SELL:                     descr = "sell"; break;
           case DEAL_TYPE_BONUS:                    descr = "bonus"; break;
           case DEAL_TYPE_COMMISSION:               descr = "additional commission"; break;
           case DEAL_TYPE_COMMISSION_DAILY:         descr = "daily commission"; break;
           case DEAL_TYPE_COMMISSION_MONTHLY:       descr = "monthly commission"; break;
           case DEAL_TYPE_COMMISSION_AGENT_DAILY:   descr = "daily agent commission"; break;
           case DEAL_TYPE_COMMISSION_AGENT_MONTHLY: descr = "monthly agent commission"; break;
           case DEAL_TYPE_INTEREST:                 descr = "interest rate"; break;
           case DEAL_TYPE_BUY_CANCELED:             descr = "cancelled buy deal"; break;
           case DEAL_TYPE_SELL_CANCELED:            descr = "cancelled sell deal"; break;
       }
   
       // Рассчитываем общую прибыль сделки
       double deal_profit = HistoryDealGetDouble(deal_ticket, DEAL_PROFIT);
       double deal_commission = HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION);
       double deal_swap = HistoryDealGetDouble(deal_ticket, DEAL_SWAP);
       double summ_profit = deal_profit + deal_commission + deal_swap;
   
       // Формируем итоговое описание сделки
       string deal_description = StringFormat(
           " %s %G %s (order #%d, position ID %d, magic %d) Profit: %G  Result: %G",
           descr,            // Тип сделки (покупка, продажа и т.д.)
           volume,           // Объём сделки
           symbol,           // Символ инструмента
           order_ticket,     // Тикет ордера
           position_ID,      // ID позиции
           deal_magic,       // Магик ордера
           deal_profit,      // Общая прибыль сделки
           summ_profit
       );
   
       // Выводим информацию по сделке
       Print("deal #", deal_ticket, " at ", transaction_time, deal_description);
   }
};


//+------------------------------------------------------------------+
//| Main script functions                                            |
//+------------------------------------------------------------------+
CAccountInfo Script;

void OnStart(void) {
    if (Script.Init()) {
        while (!IsStopped()) {
            Script.Processing();
        }
    }
    Script.Deinit();
}