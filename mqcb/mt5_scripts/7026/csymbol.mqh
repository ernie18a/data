/*

*/
//---------------------------------------------------------------------
// Класс для работы со свойствами торгового инструмента
//---------------------------------------------------------------------
class CSymbol
{
  public:
              CSymbol(void);
             ~CSymbol(void);
    datetime  FirstDateServer(void);
    datetime  FirstDateTerminal(void);
    datetime  FirstDateRAM(ENUM_TIMEFRAMES period=PERIOD_M1);

  protected:
    string  symbol;
};
//---------------------------------------------------------------------
// Конструктор по умолчанию
//---------------------------------------------------------------------
void CSymbol::CSymbol(void):symbol(Symbol())
{
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CSymbol::~CSymbol(void)
{
}
//---------------------------------------------------------------------
// Получение самой первой даты по символу на сервере
//---------------------------------------------------------------------
datetime CSymbol::FirstDateServer(void)
{
  datetime time=0;
  while(!IsStopped())
  {
    if(SeriesInfoInteger(symbol,0,SERIES_SERVER_FIRSTDATE,time)) {break;} else {Sleep(1);}
  }
  return(time);
}
//---------------------------------------------------------------------
// Получение самой первой даты по символу в терминале
//---------------------------------------------------------------------
datetime CSymbol::FirstDateTerminal(void)
{
  datetime time=0;
  while(!IsStopped())
  {
    if(SeriesInfoInteger(symbol,0,SERIES_TERMINAL_FIRSTDATE,time)) {break;} else {Sleep(1);}
  }
  return(time);
}
//---------------------------------------------------------------------
// Получение самой первой даты по символу-периоду в ОЗУ
//---------------------------------------------------------------------
datetime CSymbol::FirstDateRAM(ENUM_TIMEFRAMES period=PERIOD_M1)
{
  datetime time=0;
  while(!IsStopped())
  {
    if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,time)) {break;} else {Sleep(1);}
  }
  return(time);
}
