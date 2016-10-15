//+------------------------------------------------------------------+
//|                                        Cycle_KROUFR_version.mq4  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2008 | Grayman77, zIG, akadex"
#property  link      "ForexResearch"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20
#property indicator_level2 50
#property indicator_level3 80
#property indicator_buffers 1
#property indicator_color1 DarkOrchid

//---- input parameters
extern int FastMA=12;
extern int SlowMA=24;
extern int Crosses=50;
extern bool Comments=true; 

//---- buffers
double MA[];
double MCD[];
double MAfast[],MAslow[];
double Cross[];
double max_min[];
double PointDeviation[];
double PeriodTimeAVG[];

//---- var
double smconst,ST,max,min;
int ShiftFirstCross;  // смещение первого пересечения c начала истории
int ShiftCrossesCross;  // смещение (Crosses+1)-го пересечения c начала истории (первое - пропускаем)
int k;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//   string short_name;
//---- indicator line
   IndicatorBuffers(8);
   SetIndexBuffer(0, MA);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,DarkOrchid);
   SetIndexBuffer(1, MCD);
 	SetIndexBuffer(2, MAfast);
	SetIndexBuffer(3, MAslow);
	SetIndexBuffer(4, Cross);
	SetIndexBuffer(5, max_min);
	SetIndexBuffer(6, PointDeviation);
	SetIndexBuffer(7, PeriodTimeAVG);
   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
   SetIndexEmptyValue(7,0.0);
   
   ShiftFirstCross=0;
	ShiftCrossesCross=0;
	k=0;
	max=0.;
   min=1000000.;
   
   return(0);
  }
int deinit()
  {
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//| Schaff Trend Cycle                                               |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i,j,limit,NumberCross,BarsCross;
   double prev,MinMACD,MaxMACD,delta,Sum_max_min;
   
   if(Bars<=SlowMA) return(-1);
   
   //---- последний посчитанный бар будет пересчитан
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(limit>Bars-SlowMA-1) limit=Bars-SlowMA-1;
   
//+------------------------------------------------------------------+
//| Time AVG                                                         |
//+------------------------------------------------------------------+
   for(i=limit;i>0;i--)
     {
     Cross[i]=0.;
     // Вычислить значения средних и поместить в буферы
     MAfast[i]=iMA(NULL,Period(),FastMA,0,MODE_SMA,PRICE_CLOSE,i);
     MAslow[i]=iMA(NULL,Period(),SlowMA,0,MODE_SMA,PRICE_CLOSE,i);
     // Найти пересечения средних
     if(MAfast[i]>=MAslow[i] && MAfast[i+1]<MAslow[i+1]) // быстрая пересекает медленную снизу вверх
       {
       // Если это первое найденное пересечение - запомнить его смещение
       if(ShiftFirstCross==0) ShiftFirstCross=i;
       // Если еще не найдено Crosses+1 пересечение
       if(ShiftCrossesCross==0)
         {
         k++;
         // если найдено - запомнить
         if(k==Crosses+1) ShiftCrossesCross=i;
         }
       // Запомнить факт пересечения в буфере
       Cross[i]=1.;
       // Запомнить разность max-min в буфере
       max_min[i]=max-min;
       // Сбросить значения max и min
       max=0.;
       min=1000000.;
       }
     if(MAfast[i]<=MAslow[i] && MAfast[i+1]>MAslow[i+1]) // быстрая пересекает медленную сверху вниз
       {
       // Если это первое найденное пересечение - запомнить его смещение
       if(ShiftFirstCross==0) ShiftFirstCross=i;
       // Если еще не найдено Crosses+1 пересечение
       if(ShiftCrossesCross==0)
         {
         k++;
         // если найдено - запомнить
         if(k==Crosses+1) ShiftCrossesCross=i;
         }
       // Запомнить факт пересечения в буфере
       Cross[i]=-1.;
       // Запомнить разность max-min в буфере
       max_min[i]=max-min;
       // Сбросить значения max и min
       max=0.;
       min=1000000.;
       }
     // Выбираем максимальную цену (из High) между пересечениями и минимальную из Low
     if(max<High[i]) max=High[i];
     if(min>Low[i]) min=Low[i];
     }
   
   
   // Считаем статистику
   if(limit>ShiftCrossesCross) limit=ShiftCrossesCross;
   for(i=limit;i>0;i--)
     {
     // Найти первое пересечение (справа налево)
     j=i;
     while(Cross[j]==0.) j++;
     // Найти следующие Crosses пересечений
     NumberCross=0;
     BarsCross=0;
     Sum_max_min=0.;
     while(NumberCross<Crosses)
       {
       // Если найдено очередное пересечение
       if(Cross[j]!=0.)
         {
         NumberCross++;  // увеличить на 1 счетчик пересечений
         Sum_max_min=Sum_max_min+max_min[j];
         }
       j++;
       BarsCross++;
       }
     
     // Итоговые значения Time AVG
     PeriodTimeAVG[i]=BarsCross/Crosses;   // среднее кол-во баров между пересечениями
     PointDeviation[i]=NormalizeDouble(Sum_max_min/Crosses/2./Point,0); // ср. отклонение
     }

//+------------------------------------------------------------------+
//| Cycle                                                            |
//+------------------------------------------------------------------+
   for(i=limit;i>=0;i--)
     {
     // Вычислить MACD
     MCD[i]=iMA(NULL,0,FastMA,0, MODE_EMA, PRICE_TYPICAL, i)-
            iMA(NULL,0,SlowMA,0, MODE_EMA, PRICE_TYPICAL, i);
     
     // Найти макс. и мин. значения MACD на периоде TimeAVG
     MinMACD=MCD[i];
     MaxMACD=MCD[i];
     for(j=i+1;j<i+PeriodTimeAVG[i+1];j++)
       {
       if(MCD[j]<MinMACD) MinMACD=MCD[j];
       if(MCD[j]>MaxMACD) MaxMACD=MCD[j];
       }
     
     // Вычислить стохастик от MACD
     delta=MaxMACD-MinMACD;
     if(delta==0.)  // проверка для исключения деления на 0
      ST=50.;
      else   // если не 0 - делим
       {
       ST=(MCD[i]-MinMACD)/delta*100;
       }
      // Заполнить буфер
     prev=MA[i+1];
     MA[i]=(2./(1.+PeriodTimeAVG[i+1]/2.))*(ST-prev)+prev;
     
     //Вывести комментарии
     if (!IsTesting() && Comments)
     Comment(" Deviation: "+DoubleToStr(PointDeviation[1],0)+
     " points\n Average Amount of Bars : "+DoubleToStr(PeriodTimeAVG[1],0)+
     "\n Crosses: "+Crosses); 
       }
  
  return(0);
  }
//+------------------------------------------------------------------+