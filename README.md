# Record-Team. DB
бэкенд для LazyAPI

Авторизация пользователя - API.PersonLogin
    @Identifier - логин
   ,@PersonID OUTPUT - идентификатор персоны
   
Информация по фонду - API.FundGet
    @FundID - ID фонда
   ,@PersonID - ID персоны
   
Контакты фонда - API.FundContacts
	@FundID = ID фонда
	
Отправка приглашения - API.InviteSend
    @FundID - ID фонда
   ,@InviteeID - ID приглашенного
   ,@PersonID - ID приглашающего
   
Принять приглашение - API.InviteAccept
    @FundID - ID фонда
   ,@PersonID - ID персоны
	
Закрыть приглашение - API.InviteClose
    @FundID - ID фонда
   ,@InviteeID - ID приглашенного
   ,@PersonID - ID персоны
   
Закрытие фонда - API.FundFinish
    @FundID - ID фонда
   ,@PersonID - ID персоны
   
Перевод денег в фонд - API.FundPay
    @FundID - ID фонда
   ,@PersonID - ID персоны
   ,@Amount - сумма
   
ента событий фонда - API.FundEvents
	@FundID - ID фонда