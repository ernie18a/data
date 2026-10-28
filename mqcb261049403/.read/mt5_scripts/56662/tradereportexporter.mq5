//+------------------------------------------------------------------+
//|                                          TradeReportExporter.mq5 |
//|                                               Anatoliy Migachyov |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Anatoliy Migachyov"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#include <Trade\DealInfo.mqh> // Для работы с историей сделок

// Функция для форматирования чисел (замена точки на запятую, если нужно)
string FormatDouble(double value, int digits) {
    string result = DoubleToString(value, digits);
    StringReplace(result, ".", ","); // Заменяем точку на запятую
    return result;
}

// Функция для получения комиссии с учетом минимального значения
double GetCommissionWithMin(double commission) {
    double minCommission = 0.01; // Минимальная комиссия (1 цент)
    return (commission < minCommission) ? minCommission : commission;
}

// Функция для определения типа инструмента (криптовалюта или валюта)
bool IsCryptoCurrency(string symbol) {
    // Криптовалюты обычно имеют суффикс "USDT" или "BTC"
    if (StringFind(symbol, "USDT") != -1 || StringFind(symbol, "BTC") != -1) {
        return true;
    }
    return false;
}

// Функция для расчета комиссии в зависимости от типа инструмента
double CalculateCommission(string symbol, double volume, double price) {
    if (IsCryptoCurrency(symbol)) {
        // Комиссия для криптовалют: 0.055% в долларах за лот
        return 0.00055 * volume * price; // 0.055% = 0.00055
    } else {
        // Комиссия для валют: 6$ за лот
        return 6.0 * volume;
    }
}

void OnStart() {
    string symbol = Symbol(); // Текущий символ графика
    string timeStamp = StringReplace(TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS), ":", "."); // Заменяем двоеточия
    string fileName = "trades_" + symbol + "_" + timeStamp + ".csv"; // Имя файла с символом
    
    // Открываем файл с разделителем-запятой и кодировкой UTF-8
    int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ";");

    if (fileHandle == INVALID_HANDLE) {
        Print("Ошибка при открытии файла: ", fileName, " Код ошибки: ", GetLastError());
        return;
    }

    // Заголовки таблицы
    FileWrite(fileHandle, "Дата и время", "Актив", "Тип сделки", "Цена", "Количество", "Комиссия", "Прибыль/Убыток");

    // Указываем диапазон времени (последний год)
    datetime startTime = iTime(symbol, PERIOD_D1, 365); // Один год назад
    datetime endTime = TimeCurrent(); // Текущее время

    // Загружаем историю сделок за указанный период
    if (!HistorySelect(startTime, endTime)) {
        Print("Ошибка при загрузке истории сделок. Код ошибки: ", GetLastError());
        FileClose(fileHandle);
        return;
    }

    int totalDeals = HistoryDealsTotal();
    Print("Всего сделок в истории: ", totalDeals);

    if (totalDeals == 0) {
        Print("История сделок пуста. Убедитесь, что история загружена.");
        FileClose(fileHandle);
        return;
    }

    // Переменные для итоговых значений
    double totalProfit = 0.0;
    double totalCommission = 0.0;
    int totalFilteredDeals = 0;

    // Перебираем сделки
    for (int i = 0; i < totalDeals; i++) {
        ulong dealTicket = HistoryDealGetTicket(i);
        if (dealTicket > 0) {
            CDealInfo deal;
            deal.Ticket(dealTicket);

            string dealSymbol = deal.Symbol();
            ENUM_DEAL_TYPE dealType = deal.DealType();
            double dealPrice = deal.Price();
            double dealVolume = deal.Volume();
            double dealCommission = deal.Commission();
            double dealProfit = deal.Profit();
            ENUM_DEAL_ENTRY dealEntry = deal.Entry();

            // Фильтр по символу, объему, цене и типу сделки
            if (dealSymbol == symbol && dealVolume > 0 && dealPrice > 0 && dealProfit != 0 && (dealEntry == DEAL_ENTRY_IN || dealEntry == DEAL_ENTRY_OUT)) {
                // Определяем тип сделки
                string dealTypeStr;
                if (dealType == DEAL_TYPE_BUY) {
                    dealTypeStr = "Продажа"; // Если DEAL_TYPE_BUY, то это "Продажа"
                } else if (dealType == DEAL_TYPE_SELL) {
                    dealTypeStr = "Покупка"; // Если DEAL_TYPE_SELL, то это "Покупка"
                } else {
                    dealTypeStr = "Неизвестно"; // На случай, если тип сделки не определен
                }

                // Получаем дату и время сделки (в более компактном формате)
                datetime dealTime = deal.Time();
                string dealTimeStr = TimeToString(dealTime, TIME_DATE|TIME_MINUTES); // Формат: YYYY.MM.DD HH:MM

                // Если комиссия из истории равна 0, рассчитываем ее вручную
                if (dealCommission == 0) {
                    dealCommission = CalculateCommission(dealSymbol, dealVolume, dealPrice);
                }

                // Применяем минимальную комиссию (1 цент)
                dealCommission = GetCommissionWithMin(dealCommission);

                // Форматируем числа
                string formattedPrice = FormatDouble(dealPrice, 4);
                string formattedVolume = FormatDouble(dealVolume, 2);
                string formattedCommission = FormatDouble(dealCommission, 2);
                string formattedProfit = FormatDouble(dealProfit, 2);

                // Записываем данные в таблицу
                if (FileWrite(fileHandle, dealTimeStr, dealSymbol, dealTypeStr, formattedPrice, formattedVolume, formattedCommission, formattedProfit) <= 0) {
                    Print("Ошибка при записи сделки в файл. Код ошибки: ", GetLastError());
                    FileClose(fileHandle);
                    return;
                }

                // Суммируем итоговые значения
                totalProfit += dealProfit;
                totalCommission += dealCommission;
                totalFilteredDeals++;

                Print("Сделка добавлена в таблицу: ", dealSymbol, " Тип: ", dealTypeStr, " Прибыль/Убыток: ", formattedProfit);
            }
        }
    }

    // Записываем итоговые значения под таблицей
    FileWrite(fileHandle, ""); // Пустая строка для разделения
    FileWrite(fileHandle, "Итого:", "", "", "", "", "Комиссия:", FormatDouble(totalCommission, 2));
    FileWrite(fileHandle, "", "", "", "", "", "Прибыль/Убыток:", FormatDouble(totalProfit, 2));
    FileWrite(fileHandle, "", "", "", "", "", "Количество сделок:", IntegerToString(totalFilteredDeals));

    // Добавляем сообщение для поддержки автора
    FileWrite(fileHandle, "");
    FileWrite(fileHandle, "**********************************************");
    FileWrite(fileHandle, "💡 Поддержи автора скрипта!");
    FileWrite(fileHandle, "Если тебе понравился этот инструмент, ты можешь сказать спасибо!");
    FileWrite(fileHandle, "Просто введи код **45980** при регистрации на Bybit.");
    FileWrite(fileHandle, "Это займет всего пару секунд, но очень поможет автору! 😊");
    FileWrite(fileHandle, "Спасибо за поддержку! ❤️");
    FileWrite(fileHandle, "**********************************************");

    FileClose(fileHandle);
    Print("Данные успешно записаны в файл: ", fileName);
}