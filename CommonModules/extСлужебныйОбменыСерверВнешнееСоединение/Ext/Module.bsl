﻿

Процедура ВыделитьТокенОбмена(Токен,ТелоЗапроса,СтруктураДополнительныхПараметров, записыватьЖурнал = ложь)   экспорт

	если записыватьЖурнал = истина тогда
	ЗаписьЖурналаРегистрации("extInt_HTTPзапрос",
    	УровеньЖурналаРегистрации.Информация, , ,
    	"текст запроса  "+ТелоЗапроса);
	конецЕсли;
	
	Попытка
        ЧтениеJSON = Новый ЧтениеJSON;
        ЧтениеJSON.УстановитьСтроку(ТелоЗапроса);
		СтруктураЗапроса = ПрочитатьJSON(ЧтениеJSON);
		СтруктураЗапроса.свойство("token",Токен);
		
	Исключение
		ЗаписьЖурналаРегистрации("extInt_HTTPзапрос",
    	УровеньЖурналаРегистрации.Информация, , ,
    	"text "+ОписаниеОшибки());

	КонецПопытки;
	
	
КонецПроцедуры



Функция ЗагрузитьСообщение(ТелоЗапроса, имяСобытия)   экспорт

	Токен = "";
	СтруктураОТборов = новый структура; 
 	   
 	СтруктураДополнительныхПараметров = новый структура;
   	СтруктураДополнительныхПараметров.Вставить("СтруктураЗапроса",ТелоЗапроса);
	СтруктураДополнительныхПараметров.Вставить("имяСобытия",имяСобытия);
	
	записыватьЖурнал = истина;

	
	ВыделитьТокенОбмена(Токен,ТелоЗапроса,СтруктураДополнительныхПараметров, записыватьЖурнал);
	
	Токен = сокрЛП(Токен);  // убираем пробелы справа=слева. иначе не найдем обработку
	
	 ЗаписьЖурналаРегистрации(имяСобытия,
    	УровеньЖурналаРегистрации.Информация, , ,
    	"токен  "+Токен);

	// проверим токен   
	Если не ЗначениеЗаполнено(Токен)
		и  записыватьЖурнал = истина
		Тогда
       
       ЗаписьЖурналаРегистрации(имяСобытия,
    	УровеньЖурналаРегистрации.Информация, , ,
    	"возврат - токен не тот");

       
       Возврат  Новый HTTPСервисОтвет(400, "Invalid token");
   
   КонецЕсли;  
   
   УстановитьПривилегированныйРежим(истина);
   
      
	ОбработчикЗапроса = обработки.extIntegrationWithExternalSystems.Создать();
	РезультатОбработки = ОбработчикЗапроса.exec(Токен,СтруктураОТборов,СтруктураДополнительныхПараметров);
	
	Если РезультатОбработки.Result<>"" Тогда
		 Ответ = Новый HTTPСервисОтвет(200);
		 Ответ.УстановитьТелоИзСтроки(РезультатОбработки.Result);
		 
		 Если записыватьЖурнал = истина Тогда
		 
		 	 ЗаписьЖурналаРегистрации(имяСобытия,
	    	УровеньЖурналаРегистрации.Информация, , ,
	    	"Ответ  "+РезультатОбработки.Result);

		 
		 КонецЕсли; 
		 
			
		Для каждого заголовок Из РезультатОбработки.headers Цикл
		
			Ответ.Заголовки.Вставить(стрЗаменить(заголовок.ключ,"_", "-"), заголовок.значение);
		
		КонецЦикла;	
		
		
		
	Иначе
	 Ответ = Новый HTTPСервисОтвет(400,РезультатОбработки.DescriptionErr);

	КонецЕсли;
	 УстановитьПривилегированныйРежим(ложь);
	
	Возврат Ответ;

	

КонецФункции // ()
