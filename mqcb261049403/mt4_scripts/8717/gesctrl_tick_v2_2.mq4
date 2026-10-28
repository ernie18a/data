//+------------------------------------------------------------------+
//|                                              geSCtrl_Tick_v2.mq4 |
//|                                                         forte928 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "forte928"
#property link      ""
/*
	Скрипт предназначен для установки двух параметров смещения и кол-ва расчетных данных
	для индикатора советника или же другого скрипта	через глобальные переменные, 
	а также существует возможность автоматически проходить по диапазону данных от 
	начально установленого бара до нулего с задержкой..
	
Приведен пример индикатора линейной регресии в совместном использовании с прилагаемым скриптом..
Индикатор может выполнять расчеты как при самостоятельном выполнении так и в связке со скриптом (наличии запущеного скрипта)..
При наличии связки со скриптом параметры которые необходимы индикатору для расчета (смещение и кол-во расчетных данных)
находятся в глобальных переменных (CE_Time и CE_Count соотвественно)

скрипт имеет возможность управления индикатором как в ручном режиме (задание смещения - позиционирование обьекта линейной регресии мышкой)
или же в автоматическом (задание смещения - позиционирование обьекта линейной регресии через установку новых координат со смещением -1).
управление ручным и автоматическим режимом задается через гловальную переменную _Emulated
_Emulated=0 - ручной режим
_Emulated=1 автоматический режим..
Установка значения глобальной переменой осуществляется как через глобальные переменные "F3"
так и через удаление текстовой метки "Auto Emulate"  или "Manual Emulate" -  что приводит к изменению значения на противоположное..

при достижении обьектом нулевого бара в автоматическом режиме скрипт переходит в ручной режим управления..
глобальной переменой  _PauseCount устанавливают парамтр задержки для следующего выполнения индикатора
глобальной переменой  _CW_xxxxx - определяется готовность индикатора на выполнениея следующего расчета..
по завершению расчета индикатор выставляет флаг _CW_xxxxx=true.. 
глобальная переменая  _CW_xxxxx - формируется при инициализации индикатора и является уникальной 
для каждого добавленого индикатора индикатора на любой график со своим временым периодом..
Индикатор определяет сам необходимость пересчета данных при изменении смещения в глобальной переменной CE_Time


При выходе крайних точек объекта линейной регресии за границы экрана графика график автоматически перемещается, 
отображая новый выбранный диапазон
Завершение выполнения скрипта осуществляется удалением обьекта линейной регресии с последующим подтверждением на выгрузку
	
	Мои благодарности за начальную идею Поддубному Олегу его скрипт Mover.mq4..
*/
	//#include <WinUser32.mqh> вставлял.Надо разрешить импорт ДЛЛ в настройках МТ4.
	//PostMessageA (WindowHandle (Symbol(), 0), WM_COMMAND, 33324, 0); // Эмулируем тик для индикаторов
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
//==============================================================
//Control Emulated --> "CE_"
#include <WinUser32.mqh> // Заголовочный файл библиотеки "user32.dll" функций API Windows XP.
#include <ge_VKKeyCode.mq4>
//#include "ge_Debug.mq4"

#define WM_COMMAND   0x0111

#define gnObject		"CE_Ctrl"
#define gnLabel		"CE_Label"
#define gnCount		"CE_Count"
#define gnTime			"CE_Time"
#define gnEmulate		"_Emulated"
#define gnCalculate	"_CW_"			// Calculate Switch - префикс начала имени глобальных переменных пересчета индикаторов 
#define gnPauseCount	"_PauseCount"


#property show_inputs

//==============================================================
string	iSymbol;
int		iPeriod;
bool		IsWorking=true;					// Проверка на продолжение работоспособности скрипта
int		TimeRight,TimeLeft;				//	Текущая обрабатываемая позиция (времени)
int		TickPrd,TickLeft,TickRight;	// Текущая обрабатываемая позиция (бар)
int		TimeRSave,TimeLSave;				// Значение сохраненой позиции (времени)

int		SetBars		=0;					// установка начального бара эмуляции тиков
datetime	SetTime		=0;					//	Установка начального времени эмуляции тиков
bool		Emulated		=false;				// флаг эмуляции поступления тиков, установка значения через F3
													// false - ручная (перемещение обьекта мышкой)
													//	true	- автоматическое эмуляци поступающий тиков до "0" бара 
bool		Calculated	=false;				// флаг окончания пересчета данных (индикатор, советник или скрипт)
extern int PauseCount	=100;				// Задержка выполнения Скрипта минимальное значение 100мс.
int		PauseWait	=0;					// Счетчик паузы выполнения Скрипта в режиме эмуляции
bool		Modifed		=false;				// флаг наличия изменения позиции объекта
string	CWName		="";
int		CWCount		=0;
/*

Пример  использования в индикаторе :
символами "// -->" в конце строчек указаны строчки обязательные к вставке в код индикатора

#define		IndicatorName "LR_MA"	// данная строчка не обязательна 

...

extern int	Shift=0;			// переменая смещения начальных расчетных данных индикатора	// -->
extern int	Count=1000;		// переменая кол-ва расчетных значений индикатора

...
#include "ge_TicketCtrl.mq4"													// -->
// модуль ge_TicketCtrl.mq4 - добавляет внешную переменую extern	bool	cwEmulated=false;
// которая определяет работу индикатора как в обычном режиме - восприятия тиковых значений сервера cwEmulated=false,
// так и в режиме - восприятия эмулированных тиков cwEmulated=true
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Custom indicator initialization function ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int init()
{

		.....

	InitTicket(IndicatorName);		// Здесь нужно указать имя индикатора для определенния глобальной переменной // -->
											// _CW_xxxxx, к имени добавляется уникальный номер для избежания конфликта
											// двух одинаковых индикатора на разных периодах..
//----
	return(0);
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int deinit()
  {
//----
		...
	DoneTicket();																	// -->
//----
   return(0);
  }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~V~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int start()
{
	if (StartTicket(Shift)==false)											// -->
	{																					// -->
    int limit;
     int counted_bars=IndicatorCounted();
  //---- последний посчитанный бар будет пересчитан
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;
	}																					// -->
	else {																			// -->
		if (Calculated==true) return(0);										// -->
	}																					// -->

  //---- основной цикл
	ReadValueTicket(Shift,Ix);													// -->

	double Rates[],TimeBuf1[];
	ArrayResize(Rates);ArrayResize(TimeBuf1);
	for (Ix=0;Ix<Count;Ix++) Rates[Ix]=Close[Ix+Shift];

	LineRegressOnArray(Rates,TimeBuf1,DeGree,LRCalc);			// расчет линейной регресии результат в TimeBuf1
	// SetIndexBuffer(0, FxView1);
	ArrayCopy(FxView1,TimeBuf1,Shift,0,Count);					// отображение на линии индикатора
	

	CalculateFinishedTicket();													// -->
//----
   return(0);
  }
//+-----------------------------------------------------------------------------------------------+\\
//**************************************************************/
string EmulateState(bool iEmulate)
{
	if (iEmulate==true) return("Auto Emulate");
	else return("Manual Emulate");
}
int init() 
{
	// проверка на наличие запущегого Скрипта..
	PauseWait=500;
	if (GlobalVariableCheck(gnEmulate)==true)
	{
		GlobalVariableDel(gnEmulate);
		Sleep(PauseWait);
		if (GlobalVariableCheck(gnEmulate)==true) 
		{
			MessageBox("Подобный скрипт запущен в другом окне","",IDOK);
			return;
		}
	}
	PauseWait=0;
	
	iSymbol=Symbol();
	iPeriod=Period();
	
	TickPrd=100;
	TimeRight=WindowTimeOnDropped();//Print(TimeToStr(TimeRight,TIME_DATE|TIME_MINUTES));
	TickRight=iBarShift(NULL,iPeriod,TimeRight);
	TickLeft=WindowFirstVisibleBar();
	if ((TickLeft-TickRight)>TickPrd) TickLeft=TickRight+TickPrd;
	if ((TickLeft-TickRight)<TickPrd) TickRight=TickLeft-TickPrd;
	if (TickRight<0) {TickRight=0;TickLeft=TickPrd-1;}
   TimeLeft=Time[TickLeft];
	TimeRight=Time[TickRight];
	TimeRSave=TimeRight;
	TimeLSave=TimeLeft;
	
	ObjectCreate(gnObject,4,0,TimeLeft,0,TimeRight,0);
	ObjectSet(gnObject,OBJPROP_COLOR,Gold);
	ObjectCreate(gnLabel, OBJ_LABEL, 0, 0, 0);
	ObjectSetText(gnLabel,EmulateState(Emulated), 20, "Verdana", Yellow);
	ObjectSet(gnLabel, OBJPROP_XDISTANCE, 10);
	ObjectSet(gnLabel, OBJPROP_YDISTANCE, 50);
	
	GlobalVariableSet(gnCount,TickPrd);
	GlobalVariableSet(gnTime,TimeRight);
	GlobalVariableSet(gnEmulate,Emulated);
	//GlobalVariableSet(gnCalculate,Calculated);
	GlobalVariableSet(gnPauseCount,PauseCount);
	GlobalVariablesDeleteAll(gnCalculate);

	//PostMessageA (WindowHandle(iSymbol,iPeriod), WM_COMMAND, 33324, 0); // Обновляем окно.
	WindowRedraw();
}
//**************************************************************
int start() 
{
	if (PauseWait>0) return;
	PauseWait=0;
	int HandlWindow=WindowHandle(iSymbol,iPeriod);        
	//---- 
	while (IsWorking==true)
	{
		while(ObjectFind(gnObject)>=0)
		{
			// проверка наличия глобальныых переменных управления		
			if (GlobalVariableCheck(gnEmulate)==false) GlobalVariableSet(gnEmulate,Emulated);
			Emulated=GlobalVariableGet(gnEmulate);
			if (GlobalVariableCheck(gnPauseCount)==false) GlobalVariableSet(gnPauseCount,PauseCount);
			PauseCount=GlobalVariableGet(gnPauseCount);
			if (PauseCount<100) {PauseCount=100;GlobalVariableSet(gnPauseCount,PauseCount);}
			
			Calculated=true;
			for (CWCount=0;CWCount<GlobalVariablesTotal();CWCount++)
			{
				CWName=GlobalVariableName(CWCount);
				if (StringFind(CWName,gnCalculate, 0)==0) Calculated=Calculated*GlobalVariableGet(CWName);
			}
			//if (GlobalVariableCheck(gnCalculate)==false) GlobalVariableSet(gnCalculate,false);
			//Calculated=GlobalVariableGet(gnCalculate);

			if (ObjectFind(gnLabel)<0)
			{
				Emulated=!Emulated;GlobalVariableSet(gnEmulate,Emulated);
				ObjectCreate(gnLabel, OBJ_LABEL, 0, 0, 0);
				ObjectSetText(gnLabel,EmulateState(Emulated), 20, "Verdana", Yellow);
				ObjectSet(gnLabel, OBJPROP_XDISTANCE, 10);
				ObjectSet(gnLabel, OBJPROP_YDISTANCE, 50);
			}
     		else ObjectSetText(gnLabel,EmulateState(Emulated), 20, "Verdana", Yellow);
     		
			if (Emulated==true)
			{
				//проверка наличия окончания задержки	
				TimeRight=TimeRSave;
				TimeLeft=TimeLSave;
				PauseWait=PauseWait-100;
				if (PauseWait<=0) 
				{
					PauseWait=PauseCount;
					if (Calculated==true)
					{
						TickRight=iBarShift(NULL,iPeriod,TimeRight)-1;
						TickLeft=iBarShift(NULL,iPeriod,TimeLeft)-1;
						if (TickRight>=0)
						{
							TimeRight=Time[TickRight];
							TimeLeft=Time[TickLeft];
							ObjectSet(gnObject,OBJPROP_TIME2,TimeRight); 
							ObjectSet(gnObject,OBJPROP_TIME1,TimeLeft);
						}
						else GlobalVariableSet(gnEmulate,false); // остановка автоматической эмуляции тиков
					}
				}
				else{
					if (TimeRight!=ObjectGet(gnObject,OBJPROP_TIME2)) ObjectSet(gnObject,OBJPROP_TIME2,TimeRight); 
					if (TimeLeft!=ObjectGet(gnObject,OBJPROP_TIME1)) ObjectSet(gnObject,OBJPROP_TIME1,TimeLeft); 
					TickRight=iBarShift(NULL,iPeriod,TimeRight);
					TickLeft=iBarShift(NULL,iPeriod,TimeLeft);
				}
			}
			else {
				TimeRight=ObjectGet(gnObject,OBJPROP_TIME2); 
				TimeLeft=ObjectGet(gnObject,OBJPROP_TIME1); 
				if (TimeRight>Time[0]) TimeRight=Time[0]; 
				TickRight=iBarShift(NULL,iPeriod,TimeRight);
				TickLeft=iBarShift(NULL,iPeriod,TimeLeft);
			}
// проверка и сохранение позиции  обьекта
			TickPrd=TickLeft-TickRight;
			if (TickPrd<10) 
			{
				TickPrd=10; 
				TickLeft=TickRight+TickPrd; 
				TimeLeft=Time[TickLeft];
				ObjectSet(gnObject,OBJPROP_TIME1,TimeLeft);
			}
			if (TimeRSave!=TimeRight || TimeLSave!=TimeLeft) 
			{
				GlobalVariableSet(gnCount,TickPrd);
				TimeRSave=TimeRight;
				TimeLSave=TimeLeft;
				Modifed=true;					// наличие изменения позиции обьекта
				//Debug("Modifed");
				if (WindowFirstVisibleBar()<TickLeft)
				{
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_LEFT, 1);Sleep(50);
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_LEFT, 1);Sleep(50);
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_LEFT, 1);Sleep(50);PostMessageA(HandlWindow, WM_KEYUP, VK_LEFT, 1);
				}
				if ((WindowFirstVisibleBar()-WindowBarsPerChart())>TickRight)
				{
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_RIGHT, 1);Sleep(50);
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_RIGHT, 1);Sleep(50);
					PostMessageA(HandlWindow, WM_KEYDOWN, VK_RIGHT, 1);Sleep(50);PostMessageA(HandlWindow, WM_KEYUP, VK_RIGHT, 1);
				}
			} 
			if ((Calculated==true)&&(Modifed==true))
			{
				//GlobalVariableSet(gnCalculate,False);Print("Modifed ");
				for (CWCount=0;CWCount<GlobalVariablesTotal();CWCount++)
				{
					CWName=GlobalVariableName(CWCount);
					if (StringFind(CWName,gnCalculate, 0)==0) GlobalVariableSet(CWName,false);
				}
				GlobalVariableSet(gnTime,TimeRSave);
				//Print(TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)," : Script Tick ",TimeToStr(TimeRSave,TIME_DATE|TIME_SECONDS));
				Modifed=false;
				PostMessageA (HandlWindow, WM_COMMAND, 33324, 0); // Обновляем окно.
				PostMessageA (HandlWindow, WM_COMMAND, 2, 1); // Эммуляция тика для эксперта.
				//Debug("PostMessageA");
			}
			WindowRedraw();//PostMessageA (HandlWindow, WM_COMMAND, 33324, 0); // Обновляем окно.
			//PostMessageA (HandlWindow, WM_COMMAND, 2, 1); // Эммуляция тика для эксперта.
			Comment("TimeLeft :",TimeToStr(TimeLSave,TIME_DATE|TIME_MINUTES),"  LeftBar : ",TickLeft,"  RightBar : ",TickRight,"\n",
						WindowFirstVisibleBar(),"  ",WindowBarsPerChart());
			Sleep(100);
		}//==================== основной цикл выполнения Скрипта =====================================
		int Result=MessageBox("Завершить выполнение Скрипта ?", "Question", MB_YESNO|MB_ICONQUESTION);
		if(Result!=IDYES) 
		{
			ObjectCreate(gnObject,4,0,TimeLeft,0,TimeRight,0);
			ObjectSet(gnObject,OBJPROP_COLOR,Gold);
			WindowRedraw();//PostMessageA (WindowHandle(iSymbol,iPeriod), WM_COMMAND, 33324, 0); // Обновляем окно.
		} else IsWorking=False;
	}
//=============================================
	
	PauseWait=0;
	return(0);
}
//**************************************************************
void deinit() 
{
	if (PauseWait>0) return;
	ObjectDelete(gnObject); 
	ObjectDelete(gnLabel); 
	GlobalVariableDel(gnCount);
	GlobalVariableDel(gnEmulate);
	GlobalVariableDel(gnPauseCount);
	WindowRedraw();//PostMessageA (WindowHandle(iSymbol,iPeriod), WM_COMMAND, 33324, 0); // Обновляем окно.
	Sleep(500);
	GlobalVariablesDeleteAll(gnCalculate);
	//GlobalVariableDel(gnCalculate);
}
//**************************************************************

