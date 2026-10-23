//+------------------------------------------------------------------+
//|                                                   siLagrange.mq4 |
//|                                 Copyright © 2007 Сергеев Алексей |
//|                                                los@we.kherson.ua |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Сергеев Алексей "
#property link      "mailto: los@we.kherson.ua"

#include <WinUser32.mqh>
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 SkyBlue
#property indicator_color2 Crimson
//----
extern int Pow=3;//Степень полинома Лагранжа. Желательно 3..8
extern string ID="Lx";//Идентификатор объекта для нахождения опорных точек
extern int Shift=10;//На сколько баров продлеваем в будущее
//----
double Lx[];//Полином Лагранжа
double Lx0[];//Полином Лагранжа в будущее на shift баров

int X[];//Номера баров по которым строится полином
double Y[];//Значения цены в точках
double C[];//Коэффициенты полинома

int init()
{	
//---- indicator line
	SetIndexBuffer(0,Lx); SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(1,Lx0); SetIndexStyle(1,DRAW_LINE); SetIndexShift(1, Shift); 
	return(0);
}

void GetPoint()
{
	string name;
	int i, j=0, n = ObjectsTotal();
	ArrayResize(X, n); ArrayResize(Y, n); ArrayResize(C, n);

	for (i = 0; i<=n; i++)
	{
		name = ObjectName(i);
		if ((ObjectType(name)==OBJ_ARROW)&&(StringFind(name, ID)>=0))
		{
			X[j] = iBarShift(NULL, 0, ObjectGet(name, OBJPROP_TIME1));
			Y[j] = ObjectGet(name, OBJPROP_PRICE1);
			j++;
		}
	}
	if (j<Pow) Print("Нужно еще "+(Pow-j-1)+" опорных точек для "+ID+" полинома.");
	//Сортировка массивов (методом "пузырька")
	double y;	bool b=true;
	while (b)
	{
		i = 0; b = false;
		while (i<j-1)
		{
			if (X[i]>X[i+1])
			{
				n = X[i]; X[i] = X[i+1]; X[i+1] = n;
				y = Y[i]; Y[i] = Y[i+1]; Y[i+1] = y;
				b = true;
			}
			i++;
		}
	}
}

void Lagrange()
{
	int i, j, b;
	//1. Найдем коэффициенты полинома
	for (i = 0; i<Pow; i++)
	{
		C[i] = 1.0;
		for (j = 0; j<Pow; j++)
			 if (j != i)  C[i] = C[i]*(X[i]-X[j]);
		C[i] = Y[i]/C[i];
	}
	// 2. Теперь проходя по всем барам до масимального бара, указанного в расчете полинома 
	//расчитываем сам полином (индикатор Lx)
	int bars = X[Pow-1];
	double sx;
	for (b = 0; b<=bars; b++)
	{
		Lx[b] = 0.0;
		for (i = 0; i<Pow; i++)
		{
			sx = 1;
			for (j = 0; j<Pow; j++)
				if (j != i)	sx = sx*(b-X[j]);
			Lx[b] = Lx[b]+C[i]*sx;
		}
	}
	//3. И строем индикатор Lx0 в будущее на Shift
	for (b = -Shift; b<=0; b++)
	{
		Lx0[b+Shift] = 0.0;
		for (i = 0; i<Pow; i++)
		{
			sx = 1;
			for (j = 0; j<Pow; j++)
				if (j != i)	sx = sx*(b-X[j]);
			Lx0[b+Shift] = Lx0[b+Shift]+C[i]*sx;
		}
	}
}

int start()
{
	//1. Определяем таблицу значений X и Y для построения полинома 
	GetPoint();
	//2.Строим полином
	Lagrange();
	//----
	return(0);
}
//+------------------------------------------------------------------+