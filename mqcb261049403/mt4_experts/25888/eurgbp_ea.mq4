//+------------------------------------------------------------------+
//|                                                    EurGbp EA.mq4 |
//|                                Copyright 2019, Baskakov Vladimir |
//|                        https://www.mql5.com/ru/users/kalipso1979 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Baskakov Vladimir"
#property link      "https://www.mql5.com/ru/users/kalipso1979"
#property version   "1.4"
#property strict
// Объём сделки
input double _Lots = 0.01;//Lots

// Stop Loss (в пунктах)
input int _SL = 75;//Stop Loss

// Take Profit (в пунктах)
input int _TP = 46;//Take Profit

// Magic Number (метка "своих" сделок для робота)
input int _MagicNumber = 46226;//Magic

// Комментарий для сделок
input string _Comment = "EurGbp EA";//Comments

// Допустимое проскальзывание
 int _Slippage = 5;

// Одновременно не более одной сделки
bool _OnlyOneOpenedPos = true;

// Автоучёт числа знаков цены
 bool _AutoDigits = true;

// --- 
// MACD_eur1
 int fast_ema = 12;
 int slow_ema = 26;
 int macd_sma = 9;
 int apply = 0;
// --- 
// MACD_gbp1
 int fast_ema_2 = 12;
 int slow_ema_2 = 26;
 int macd_sma_2 = 9;
 int apply_2 = 0;
// --- 
// MACD_eur
 int fast_ema_3 = 12;
 int slow_ema_3 = 26;
 int macd_sma_3 = 9;
 int apply_3 = 0;
// --- 
// MACD_gbp
 int fast_ema_4 = 12;
 int slow_ema_4 = 26;
 int macd_sma_4 = 9;
 int apply_4 = 0;

// ---
double OP_LOTS = 0.0;
// ---
// MQL4 | класс автоопределния числа знаков после запятой у текущего инструмента | ENSED Team, http://ensed.org
class CKDig
{
   public:
      CKDig(const bool useAutoDigits)
      {
         Set(useAutoDigits);
      }
      
      ~CKDig(void)
      {
      }
      
      uint Get(void)
      {
         return m_value;
      }
      
   private:      
      uint m_value;      
      
      void Set(const bool useAutoDigits)
      {
         m_value = 1;
         if (!useAutoDigits)
         {
            return;
         }
         
         if (Digits() == 3 || Digits() == 5)
         {
            m_value = 10;
         }
      }
};

CKDig *KDig;
#define K_DIG (KDig.Get())

datetime LAST_BUY_BARTIME = 0;
datetime LAST_SELL_BARTIME = 0;

// ---
void OnInit()
{
	// ---
	get_lots_by_input();
	// ---
	KDig  = new CKDig(_AutoDigits);
}

// ---
void OnDeinit(const int reason)
{
	// ---
	// ---
	if(CheckPointer(KDig))
	{
	   delete KDig;
	}
}

// ---
void OnTick()
{
	// ---
	// закрытие сделки
	if(find_orders(_MagicNumber))
	{
		if(cl_buy_sig())
		{
			cbm(_MagicNumber, _Slippage, OP_BUY);
		}
		if(cl_sell_sig())
		{
			cbm(_MagicNumber, _Slippage, OP_SELL);
		}
	}
	
	// открытие сделки
	// ---
	
	// ---
	if(!find_orders(_MagicNumber, (_OnlyOneOpenedPos ? -1 : OP_BUY)))
	{
		if(op_buy_sig() && LAST_BUY_BARTIME != iTime(Symbol(), Period(), 0))
		{
			LAST_BUY_BARTIME = iTime(Symbol(), Period(), 0);
			open_positions(OP_BUY, OP_LOTS);	
		}
	}
	// ---
	if(!find_orders(_MagicNumber, (_OnlyOneOpenedPos ? -1 : OP_SELL)))
	{
		if(op_sell_sig() && LAST_SELL_BARTIME != iTime(Symbol(), Period(), 0))
		{
			LAST_SELL_BARTIME = iTime(Symbol(), Period(), 0);
			open_positions(OP_SELL, OP_LOTS);	
		}
	}
}

// ---

// ---
// ---
void get_lots_by_input() 
{
//MQL4 | присвоение объёма по входному параметру | ENSED Team
  OP_LOTS = _Lots;
   double MinLot = MarketInfo(Symbol(),MODE_MINLOT);
  double MaxLot = MarketInfo(Symbol(),MODE_MAXLOT);
  double LotStep = MarketInfo(Symbol(),MODE_LOTSTEP);

  if (OP_LOTS < MinLot) OP_LOTS = MinLot;
  if (OP_LOTS > MaxLot) OP_LOTS = MaxLot;
}

// ---
// ---
bool find_orders(int magic = -1, int type = -1, int time = -1, string symb = "NULL", double price = -1, double lot = -1)
{
	// MQL4 | функция поиска открытых ордеров | ENSED Team, http://ensed.org
	// возвращает истину, если найден хотя бы один ордер с подходящими параметрами
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			break;
		if (((OrderType() == type) || (type == -1))
			&& ((OrderMagicNumber() == magic) || (magic == -1))
			&& ((OrderSymbol() == symb) || (symb == "NULL" && OrderSymbol() == Symbol()))
			&& ((OrderOpenTime() >= time) || (time == -1))
			&& ((OrderLots() == lot) || (lot == -1))
			&& ((NormalizeDouble(OrderOpenPrice(), Digits) == NormalizeDouble(price, Digits)) || (price == -1)))
		{
			return (true);
			break;
		}
	}
	return (false);
}

// ---
string Market_Err_To_Str(int errCode)
{
	// MQL4 | функция расшифровки кодов ошибок | ENSED Team, http://ensed.org
	// функция охватывает только коды ошибок торговых операций
	string errText;
	switch (errCode)
	{
	case 0:
		errText = "Нет ошибок";
		break;
	case 1:
		errText = "Нет ошибки, но результат неизвестен";
		break;
	case 2:
		errText = "Общая ошибка";
		break;
	case 3:
		errText = "Неправильные параметры";
		break;
	case 4:
		errText = "Торговый сервер занят";
		break;
	case 5:
		errText = "Старая версия клиентского терминала";
		break;
	case 6:
		errText = "Нет связи с торговым сервером";
		break;
	case 7:
		errText = "Недостаточно прав";
		break;
	case 8:
		errText = "Слишком частые запросы";
		break;
	case 9:
		errText = "Недопустимая операция нарушающая функционирование сервера";
		break;
	case 64:
		errText = "Счет заблокирован";
		break;
	case 65:
		errText = "Неправильный номер счета";
		break;
	case 128:
		errText = "Истек срок ожидания совершения сделки";
		break;
	case 129:
		errText = "Неправильная цена";
		break;
	case 130:
		errText = "Неправильные стопы";
		break;
	case 131:
		errText = "Неправильный объем";
		break;
	case 132:
		errText = "Рынок закрыт";
		break;
	case 133:
		errText = "Торговля запрещена";
		break;
	case 134:
		errText = "Недостаточно денег для совершения операции";
		break;
	case 135:
		errText = "Цена изменилась";
		break;
	case 136:
		errText = "Нет цен";
		break;
	case 137:
		errText = "Брокер занят";
		break;
	case 138:
		errText = "Новые цены";
		break;
	case 139:
		errText = "Ордер заблокирован и уже обрабатывается";
		break;
	case 140:
		errText = "Разрешена только покупка";
		break;
	case 141:
		errText = "Слишком много запросов";
		break;
	case 145:
		errText = "Модификация запрещена, так как ордер слишком близок к рынку";
		break;
	case 146:
		errText = "Подсистема торговли занята";
		break;
	case 147:
		errText = "Использование даты истечения ордера запрещено брокером";
		break;
	case 148:
		errText = "Количество открытых и отложенных ордеров достигло предела, установленного брокером.";
		break;
	case 4000:
		errText = "Нет ошибки";
		break;
	case 4001:
		errText = "Неправильный указатель функции";
		break;
	case 4002:
		errText = "Индекс массива - вне диапазона";
		break;
	case 4003:
		errText = "Нет памяти для стека функций";
		break;
	case 4004:
		errText = "Переполнение стека после рекурсивного вызова";
		break;
	case 4005:
		errText = "На стеке нет памяти для передачи параметров";
		break;
	case 4006:
		errText = "Нет памяти для строкового параметра";
		break;
	case 4007:
		errText = "Нет памяти для временной строки";
		break;
	case 4008:
		errText = "Неинициализированная строка";
		break;
	case 4009:
		errText = "Неинициализированная строка в массиве";
		break;
	case 4010:
		errText = "Нет памяти для строкового массива";
		break;
	case 4011:
		errText = "Слишком длинная строка";
		break;
	case 4012:
		errText = "Остаток от деления на ноль";
		break;
	case 4013:
		errText = "Деление на ноль";
		break;
	case 4014:
		errText = "Неизвестная команда";
		break;
	case 4015:
		errText = "Неправильный переход";
		break;
	case 4016:
		errText = "Неинициализированный массив";
		break;
	case 4017:
		errText = "Вызовы DLL не разрешены";
		break;
	case 4018:
		errText = "Невозможно загрузить библиотеку";
		break;
	case 4019:
		errText = "Невозможно вызвать функцию";
		break;
	case 4020:
		errText = "Вызовы внешних библиотечных функций не разрешены";
		break;
	case 4021:
		errText = "Недостаточно памяти для строки, возвращаемой из функции";
		break;
	case 4022:
		errText = "Система занята";
		break;
	case 4050:
		errText = "Неправильное количество параметров функции";
		break;
	case 4051:
		errText = "Недопустимое значение параметра функции";
		break;
	case 4052:
		errText = "Внутренняя ошибка строковой функции";
		break;
	case 4053:
		errText = "Ошибка массива";
		break;
	case 4054:
		errText = "Неправильное использование массива-таймсерии";
		break;
	case 4055:
		errText = "Ошибка пользовательского индикатора";
		break;
	case 4056:
		errText = "Массивы несовместимы";
		break;
	case 4057:
		errText = "Ошибка обработки глобальныех переменных";
		break;
	case 4058:
		errText = "Глобальная переменная не обнаружена";
		break;
	case 4059:
		errText = "Функция не разрешена в тестовом режиме";
		break;
	case 4060:
		errText = "Функция не разрешена";
		break;
	case 4061:
		errText = "Ошибка отправки почты";
		break;
	case 4062:
		errText = "Ожидается параметр типа string";
		break;
	case 4063:
		errText = "Ожидается параметр типа integer";
		break;
	case 4064:
		errText = "Ожидается параметр типа double";
		break;
	case 4065:
		errText = "В качестве параметра ожидается массив";
		break;
	case 4066:
		errText = "Запрошенные исторические данные в состоянии обновления";
		break;
	case 4067:
		errText = "Ошибка при выполнении торговой операции";
		break;
	case 4099:
		errText = "Конец файла";
		break;
	case 4100:
		errText = "Ошибка при работе с файлом";
		break;
	case 4101:
		errText = "Неправильное имя файла";
		break;
	case 4102:
		errText = "Слишком много открытых файлов";
		break;
	case 4103:
		errText = "Невозможно открыть файл";
		break;
	case 4104:
		errText = "Несовместимый режим доступа к файлу";
		break;
	case 4105:
		errText = "Ни один ордер не выбран";
		break;
	case 4106:
		errText = "Неизвестный символ";
		break;
	case 4107:
		errText = "Неправильный параметр цены для торговой функции";
		break;
	case 4108:
		errText = "Неверный номер тикета";
		break;
	case 4109:
		errText = "Торговля не разрешена. Необходимо включить опцию Разрешить советнику торговать в свойствах эксперта.";
		break;
	case 4110:
		errText = "Длинные позиции не разрешены. Необходимо проверить свойства эксперта.";
		break;
	case 4111:
		errText = "Короткие позиции не разрешены. Необходимо проверить свойства эксперта.";
		break;
	case 4200:
		errText = "Объект уже существует";
		break;
	case 4201:
		errText = "Запрошено неизвестное свойство объекта";
		break;
	case 4202:
		errText = "Объект не существует";
		break;
	case 4203:
		errText = "Неизвестный тип объекта";
		break;
	case 4204:
		errText = "Нет имени объекта";
		break;
	case 4205:
		errText = "Ошибка координат объекта";
		break;
	case 4206:
		errText = "Не найдено указанное подокно";
		break;
	default:
		errText = "Ошибка при работе с объектом";
	}
	// ---
	return (errText);
}

// ---
void open_positions(int signal, double lot, double price = 0.0, string symb = "NONE", int mode = 0)
{
	// MQL4 | функция открытия ордеров | ENSED Team, http://ensed.org
	RefreshRates();
	// ---
	int symbDigits = 0;
	string _symb = symb;
	// ---
	if (_symb == "NONE")
	{
		symbDigits = Digits;
		_symb = Symbol();
	}
	else
		symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	// ---
	//---
	    if((AccountFreeMarginCheck(_symb,OP_BUY,lot)<=0) || (GetLastError()==134))
      {
         Print(_symb," ",lot," Not enough money. ");
         return;
      }
	if (signal == OP_BUY)
		price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits); // цена открытия для покупок
		 if((AccountFreeMarginCheck(_symb,OP_SELL,lot)<=0) || (GetLastError()==134))
      {
         Print(_symb," ",lot," Not enough money. ");
         return;
      }
	if (signal == OP_SELL)
		price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits); // цена открытия для продаж
	// ---
	int err = 0;
	for (int i = 0; i <= 5; i++)
	{
	   RefreshRates();
	   // ---
		int ticket = OrderSend(_symb, // символ
			signal, // тип ордера
			lot, // объем
			NormalizeDouble(price, symbDigits), // цена открытия
			_Slippage * KDig.Get(), // уровень допустимого реквота
			0, // Stop Loss
			0, // Take Profit
			_Comment, // комментарий ордера
			_MagicNumber, // магическое число
			0, // срок истечения (используется в отложенных ордерах)
			CLR_NONE); // цвет отображаемой стрелки на графике (CLR_NONE - стрелка не рисуется)
		// ---
		if (ticket != -1)
		{
			err = 0;
			// ---
			if (!IsTesting())
				Sleep(1000);
			// ---
			RefreshRates();
			// ---
			if(_SL != 0 || _TP != 0)
			{
				for (int tryModify = 0; tryModify <= 5; tryModify++)
				{
					RefreshRates();
					// ---
					if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
					{
						double sl = NormalizeDouble(get_sl(_SL * KDig.Get(), signal, price, _symb), symbDigits);
						double tp = NormalizeDouble(get_tp(_TP * KDig.Get(), signal, price, _symb), symbDigits);
						// ---
						if (sl != 0 || tp != 0)
   						if (OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, OrderExpiration()))
   							break;
						// ---
						err = GetLastError(); // получаем код ошибки модификации
					}
					// ---
					if (!IsTesting())
						Sleep(tryModify*1000);
				}
				// ---
				if (err != 0)
					Alert("Ошибка выставления SL/TP: " + Market_Err_To_Str(err));
			}
			// ---
			break;
		}
		else
		{
			err = GetLastError(); // получаем код ошибки открытия
			// ---
			if (err == 0)
				break;
			// ---
			i++;
			// ---
			if (!IsTesting())
				Sleep(i*500); // в случае ошибки делаем паузу перед новой попыткой
		}
	}
	// ---
	if (err != 0)
	{
		if(signal == OP_BUY)
			LAST_BUY_BARTIME = 0;
		if(signal == OP_SELL)
			LAST_SELL_BARTIME = 0;
		Alert("Ошибка открытия: "  + Market_Err_To_Str(err)); // если есть ошибка - выводим сообщение
	}
}

// ---
double get_tp(int tp_value, int type, double price = 0.0, string symb = "NONE")
{
	// MQL4 | функция расчета величины Take Profit для ордеров | ENSED Team, http://ensed.org
	double _price = price;
	string _symb = symb;
	// ---
	if (_symb == "NONE")
		_symb = Symbol();
	int symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	// ---
	if (_price == 0)
	{
		if (type == OP_BUY)
			_price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits);
		// ---
		if (type == OP_SELL)
			_price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits);
	}
	// ---
	if (tp_value > 0)
	{
		if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP)
			return NormalizeDouble(_price + tp_value * MarketInfo(_symb, MODE_POINT), symbDigits);
		// ---
		if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
			return NormalizeDouble(_price - tp_value *  MarketInfo(_symb, MODE_POINT), symbDigits);
	}
	// ---
	return 0.0;
}

// ---
double get_sl(int sl_value, int type, double price = 0.0, string _symb = "NONE")
{
	// MQL4 | функция расчета величины Stop Loss для ордеров по фиксированному значению SL | ENSED Team, http://ensed.org
	if (_symb == "NONE")
		_symb = Symbol();
	int symbDigits = int(MarketInfo(_symb, MODE_DIGITS));
	double symbPoint = MarketInfo(_symb, MODE_POINT);
	// ---
	if (price == 0.0)
	{
		if (type == OP_BUY)
			price = NormalizeDouble(MarketInfo(_symb, MODE_ASK), symbDigits);
		if (type == OP_SELL)
			price = NormalizeDouble(MarketInfo(_symb, MODE_BID), symbDigits);
	}
	// ---
	if (sl_value > 0)
	{
		if (type == OP_BUY || type == OP_BUYLIMIT || type == OP_BUYSTOP)
			return NormalizeDouble(price - sl_value * symbPoint, symbDigits);
		if (type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
			return NormalizeDouble(price + sl_value * symbPoint, symbDigits);
	}
	// ---
	return 0.0;
}

// ---
bool close_by_ticket(const int ticket, const int slippage)
{
	/*
	 MQL4 | функция закрытия сделки по её номеру (тикету) | ENSED Team
	 При закрытии рыночного ордера учитывается уровень максимально допустимого проскальзывания (slipage)
	 */
	if (!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)) // выбираем ордер по тикету
	{
	   return false;
	}
	
	int err = 0;
	
	for (int i = 0; i < 5; i++)
	{
	   ResetLastError();
	   
		RefreshRates();
		
		double price = 0.0;
		
		if (OrderType() == OP_BUY)
		{
			price = NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID), (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
		}
		if (OrderType() == OP_SELL)
		{
			price = NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK), (int)SymbolInfoInteger(OrderSymbol(), SYMBOL_DIGITS));
		}
				   
	   // если рыночный ордер - закрываем его, если отложенный - удаляем
	   bool result = false;
	   
		if (OrderType() <= OP_SELL) 
		{
			result = OrderClose(OrderTicket(), OrderLots(), price, slippage * KDig.Get(), clrNONE);
	   }
		else
		{
			result = OrderDelete(OrderTicket());
		}
		
		if (result) // если закрытие или удаление прошло успешно - возвращаем true и выходим из цикла
		{
			return (true);
		}
		
		err = GetLastError();
		
		if (err != 0)
		{
			Print("Error of close_by_ticket() #" + (string)err + ": " + Market_Err_To_Str(err)); // если есть ошибка - даём расшифровку её кода в журнал
		}
		
		Sleep(300 * i);
	}
	return (false);
}

// ---
bool cbm(int magic, int slippage, int type)
{
	/*
	 close by magic (закрытие всех ордеров данного типа с данным MagicNumber)
	 Учитывается максимально допустимое проскальзывание (slipage)
	 Используется функция close_by_ticket.
	 */
	int n = 0;
	RefreshRates();
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			break;
		if ((OrderType() == type) && (OrderMagicNumber() == magic) && (Symbol() == OrderSymbol()))
		{
			close_by_ticket(OrderTicket(), slippage); // закрываем сделку
			n++; // наращиваем счётчик закрытых сделок (на самом деле - попыток закрытия)
		}
	}
	if (n > 0) // если попыток закрытия было больше 0, то функция возвращает true
			return (true);
	return (false);
}

double e_MACD_eur1()
{
	return iMACD("EURUSD", PERIOD_H1, fast_ema, slow_ema, macd_sma, apply, 0, 2);
}
double e_MACD_gbp1()
{
	return iMACD("GBPUSD", PERIOD_H1, fast_ema_2, slow_ema_2, macd_sma_2, apply_2, 0, 2);
}
double e_MACD_eur()
{
	return iMACD("EURUSD", PERIOD_H1, fast_ema_3, slow_ema_3, macd_sma_3, apply_3, 0, 1);
}
double e_MACD_gbp()
{
	return iMACD("GBPUSD", PERIOD_H1, fast_ema_4, slow_ema_4, macd_sma_4, apply_4, 0, 1);
}
// ---
bool op_buy_sig()
{
	if((e_MACD_eur1() < e_MACD_gbp1()) && (e_MACD_eur() > e_MACD_gbp()))
		return true;
	// ---
	return false;
}
// ---
bool op_sell_sig()
{
	if((e_MACD_gbp1() < e_MACD_eur1()) && (e_MACD_gbp() > e_MACD_eur()))
		return true;
	// ---
	return false;
}
// ---
bool cl_buy_sig()
{
	return false;
}
// ---
bool cl_sell_sig()
{
	return false;
}

