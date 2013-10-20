PROCEDURE af_vygrbank
LPARAMETERS NCALLCODE, OCALLER, NPROGRAM

IF NCALLCODE=0
	DIMENSION CAF_UNIT[1], CAF_NAME[1]
	CAF_UNIT[1] = 'Bank'
	CAF_NAME[1] = 'Экспорт в Клиент-Банк ООО "ЭКСПОБАНК"'
	RETURN
ENDIF

IF NCALLCODE=1

	DO CASE
		CASE NPROGRAM=1
			= EXPTOCLIENTBANKAS1C(OCALLER)
	ENDCASE
ENDIF
ENDPROC
**

PROCEDURE ExpToClientBankAs1C
LPARAMETERS OCALLER
PAT = CREATEOBJECT('MyClass')

LOCAL cFIleName
cFilename='1c_to_kl.txt'




DO FORM af_vygrbank
IF !PAT.LYES OR RECCOUNT('vbank')=0
RETURN
ENDIF
DIMENSION AMARKKEYS[ALEN(OCALLER.UNIT.ACTIVETABLE.GRID.MARKKEYS)]
= ACOPY(OCALLER.UNIT.ACTIVETABLE.GRID.MARKKEYS, AMARKKEYS)
CREATE CURSOR Rn (RN C (4))
DIMENSION CRN[1]
SELECT RN
FOR NSTR = 1 TO ALEN(AMARKKEYS)
IF ISNULL(AMARKKEYS(1))
CRN[1] = VBANK.RN
ELSE
CRN[1] = AMARKKEYS(NSTR)
ENDIF
APPEND FROM ARRAY CRN
ENDFOR
USE bankacc AGAIN IN 0
USE orgbase AGAIN IN 0
USE bklsdoh AGAIN IN 0
PAT.CPATH = ALLTRIM(PAT.CPATH)

IF FILE(PAT.CPATH+cFIleName)
	DELETE FILE PAT.CPATH+cFIleName
ENDIF

SELECT VBANK.* FROM vbank, rn WHERE VBANK.RN=RN.RN INTO CURSOR arbank ORDER BY date_doc
GO TOP 
LOCAL dMin, dMax
dMIn = arbank.date_doc
GO BOTTOM 
dMax = arbank.date_doc

FL = FCREATE(PAT.CPATH+cFIleName)
= FPUTS(FL, '1CClientBankExchange')
= FPUTS(FL, 'ВерсияФормата=1.01')
= FPUTS(FL, 'Кодировка=Windows')
= FPUTS(FL, 'Клиент-Банк РФК')
= FPUTS(FL, 'ДатаСоздания='+DTOC(OSYSTEM.DATE))
FPUTS(Fl, 'ВремяСоздания='+PADL(TIME(), 8))
FPUTS(Fl, 'ДатаНачала='+DTOC(dMin))
FPUTS(Fl, 'ДатаКонца='+DTOC(dMax))
= FPUTS(FL, 'Документ=Платежное поручение')
SELECT arbank 
GOTO TOP
SCAN
= FPUTS(FL, 'СекцияДокумент=Платежное поручение')
= FPUTS(FL, 'Номер='+ALLTRIM(NUM_DOC))
= FPUTS(FL, 'Дата='+IIF(DAY(DATE_DOC)<10, '0', '')+ALLTRIM(STR(DAY(DATE_DOC), 2))+'.'+IIF(MONTH(DATE_DOC)<10, '0', '')+ALLTRIM(STR(MONTH(DATE_DOC), 2))+'.'+ALLTRIM(STR(YEAR(DATE_DOC), 4)))
= FPUTS(FL, 'Сумма='+ALLTRIM(CHRTRAN(STR(SUMMA_ITOG, 15, 2), ',', '.')))
= FPUTS(FL, 'ПлательщикСчет='+ALLTRIM(IIF(!EMPTY(RN_REK_FR), GETTABLEFIELD('bankacc', 'account', RN_ORG_FR+RN_REK_FR, 'rn'), '')))
= FPUTS(FL, 'ПлательщикИНН='+ALLTRIM(SUBSTR(GETTABLEFIELD('orgbase', 'inn', RN_ORG_FR, 'rn'), 1, AT('/', GETTABLEFIELD('orgbase', 'inn', RN_ORG_FR, 'rn'))-1)))
= FPUTS(FL, 'Плательщик=ИНН '+ALLTRIM(IIF(!EMPTY(RN_REK_FR), GETTABLEFIELD('bankacc', 'account', RN_ORG_FR+RN_REK_FR, 'rn'), ''))+ALLTRIM(GETTABLEFIELD('orgbase', 'showname', RN_ORG_FR, 'rn')))
= FPUTS(FL, 'Плательщик1='+ALLTRIM(GETTABLEFIELD('orgbase', 'showname', RN_ORG_FR, 'rn')))
= FPUTS(FL, 'ПлательщикБанк1=ООО "ЭКСПОБАНК"')
= FPUTS(FL, 'ПлательщикБанк2=Г. МОСКВА')
= FPUTS(FL, 'ПлательщикКорсчет='+ALLTRIM(IIF(!EMPTY(RN_REK_FR), GETTABLEFIELD('bankacc', 'accountc', RN_ORG_FR+RN_REK_FR, 'rn'), '')))
= FPUTS(FL, 'ПлательщикБИК='+ALLTRIM(IIF(!EMPTY(RN_REK_FR), GETTABLEFIELD('bankacc', 'bankbic', RN_ORG_FR+RN_REK_FR, 'rn'), '')))
= FPUTS(FL, 'ПолучательСчет='+ALLTRIM(IIF(!EMPTY(RN_REK_TO), GETTABLEFIELD('bankacc', 'account', RN_ORG_TO+RN_REK_TO, 'rn'), '')))
= FPUTS(FL, 'Получатель='+ALLTRIM(GETTABLEFIELD('orgbase', 'showname', RN_ORG_TO, 'rn')))
= FPUTS(FL, 'Получатель1='+ALLTRIM(GETTABLEFIELD('orgbase', 'showname', RN_ORG_TO, 'rn')))
= FPUTS(FL, 'ПолучательИНН='+ALLTRIM(SUBSTR(GETTABLEFIELD('orgbase', 'inn', RN_ORG_TO, 'rn'), 1, AT('/', GETTABLEFIELD('orgbase', 'inn', RN_ORG_TO, 'rn'))-1)))
= FPUTS(FL, 'ПолучательБанк1='+ALLTRIM(IIF(!EMPTY(RN_REK_TO), GETTABLEFIELD('bankacc', 'bankname', RN_ORG_TO+RN_REK_TO, 'rn'), '')))
= FPUTS(FL, 'ПолучательБанк2=')
= FPUTS(FL, 'ПолучательБИК='+ALLTRIM(IIF(!EMPTY(RN_REK_TO), GETTABLEFIELD('bankacc', 'bankbic', RN_ORG_TO+RN_REK_TO, 'rn'), '')))
= FPUTS(FL, 'ПолучательКорсчет='+ALLTRIM(IIF(!EMPTY(RN_REK_TO), GETTABLEFIELD('bankacc', 'accountc', RN_ORG_TO+RN_REK_TO, 'rn'), '')))
= FPUTS(FL, 'ВидПлатежа=электронно')
= FPUTS(FL, 'ВидОплаты=01')
= FPUTS(FL, 'Очередность='+ALLTRIM(STR(TURN_PAY)))
= FPUTS(FL, 'НазначениеПлатежа='+ALLTRIM(NOTE))
= FPUTS(FL, 'НазначениеПлатежа1='+GETWORDNUM(NOTE, 1, '.'))
= FPUTS(FL, 'НазначениеПлатежа2='+GETWORDNUM(NOTE, 2, '.'))
= FPUTS(FL, 'НазначениеПлатежа3='+GETWORDNUM(NOTE, 3, '.'))
= FPUTS(FL, 'СтатусСоставителя='+TAXSTATE)
= FPUTS(FL, 'ПлательщикКПП='+ALLTRIM(SUBSTR(GETTABLEFIELD('orgbase', 'inn', RN_ORG_FR, 'rn'), AT('/', GETTABLEFIELD('orgbase', 'inn', RN_ORG_FR, 'rn'))+1)))
= FPUTS(FL, 'ПолучательКПП='+ALLTRIM(SUBSTR(GETTABLEFIELD('orgbase', 'inn', RN_ORG_TO, 'rn'), AT('/', GETTABLEFIELD('orgbase', 'inn', RN_ORG_TO, 'rn'))+1)))
= FPUTS(FL, 'ПоказательКБК='+ALLTRIM(IIF(!EMPTY(KBK_RN), GETTABLEFIELD('bklsdoh', 'code', KBK_RN, 'rn'), '')))
= FPUTS(FL, 'ОКАТО='+ALLTRIM(GETTABLEFIELD('orgbase', 'okato', RN_ORG_FR, 'rn')))
= FPUTS(FL, 'ПоказательОснования='+IIF(!EMPTY(RN_PAY), GETTABLEFIELD('comdicbs', 'code', RN_PAY, 'rn'), ''))
= FPUTS(FL, 'ПоказательПериода='+IIF(!EMPTY(KBK_RN), LEFT(DATE_TRANS, 2)+'.'+SUBSTR(DATE_TRANS, 3, 2)+'.'+SUBSTR(DATE_TRANS, 5, 4), ''))
= FPUTS(FL, 'ПоказательНомера='+IIF(!EMPTY(KBK_RN), '0', ''))
= FPUTS(FL, 'ПоказательДаты='+IIF(!EMPTY(DATE_B_PAY), IIF(DAY(DATE_B_PAY)<10, '0', '')+ALLTRIM(STR(DAY(DATE_B_PAY), 2))+'.'+IIF(MONTH(DATE_B_PAY)<10, '0', '')+ALLTRIM(STR(MONTH(DATE_B_PAY), 2))+'.'+ALLTRIM(STR(YEAR(DATE_B_PAY), 4)), ''))
= FPUTS(FL, 'ПоказательТипа='+IIF(!EMPTY(RN_TRANS), GETTABLEFIELD('comdicbs', 'code', RN_TRANS, 'rn'), ''))
= FPUTS(FL, 'КонецДокумента')
ENDSCAN
= FPUTS(FL, 'КонецФайла')
= FFLUSH(FL)
= FCLOSE(FL)
= MESSAGEBOX('Выгрузка успешно завершена!', 64, 'Экспорт ПП в Клиент-банк')
ENDPROC
**
DEFINE CLASS MyClass AS Custom
CPATH = ''
LYES = .F.
ENDDEFINE


**************************************************
*-- Form:         af_fygrbank (c:\documents and settings\андрей\мои документы\visual foxpro projects\экспорт пп 1с\af_vygrbank.scx)
*-- ParentClass:  tdialog (c:\documents and settings\parusish\7хх-12-2004\common\vcx1\windows.vcx)
*-- BaseClass:    form
*-- Time Stamp:   07/17/05 12:28:10 PM
*
DEFINE CLASS af_fygrbank AS tdialog


	Height = 145
	Width = 360
	DoCreate = .T.
	Caption = ['Экспорт ПП в "Клиентбанк"']
	Name = "af_fygrbank"
	oFocus.Name = "oFocus"


	ADD OBJECT tdialogpanel1 AS tdialogpanel WITH ;
		Top = 0, ;
		Left = 0, ;
		Width = 360, ;
		Height = 96, ;
		Name = "Tdialogpanel1"


	ADD OBJECT t3dshape1 AS t3dshape WITH ;
		Top = 12, ;
		Left = 12, ;
		Height = 72, ;
		Width = 336, ;
		Name = "T3dshape1"


	ADD OBJECT catalog AS tdirselect WITH ;
		Top = 36, ;
		Left = 24, ;
		Width = 312, ;
		Height = 23, ;
		Name = "Catalog", ;
		CMD.Name = "CMD", ;
		Dir.Top = -5, ;
		Dir.Left = 0, ;
		Dir.Height = 100, ;
		Dir.Width = 100, ;
		Dir.Name = "Dir", ;
		Text.Name = "Text"


	ADD OBJECT tlabel1 AS tlabel WITH ;
		Caption = "Каталог:", ;
		Left = 24, ;
		Top = 7, ;
		Name = "Tlabel1"


	ADD OBJECT tbutton1 AS tbutton WITH ;
		Top = 108, ;
		Left = 84, ;
		Caption = "ОК", ;
		Default = .T., ;
		Name = "Tbutton1"


	ADD OBJECT tbutton2 AS tbutton WITH ;
		Top = 108, ;
		Left = 192, ;
		Caption = "Отмена", ;
		Name = "Tbutton2"


	**
	PROCEDURE Init
		PRIVATE SAV_NFILEPATH
		SAV_NFILEPATH = ""
		= MEMOFILE("mem_ppexp", 2)
		THISFORM.CATALOG.TEXT.VALUE = SAV_NFILEPATH
		IF EMPTY(THISFORM.CATALOG.TEXT.VALUE)
		THISFORM.CATALOG.TEXT.VALUE = "c:\"
		ENDIF
	ENDPROC
		**

		*--
		*-- ORIGINAL METHODS BELOW (inside #IF ... #ENDIF)
		*--
		#IF .F.
	PROCEDURE Init
		Private  sav_nFilePath
		sav_nFilePath     = ""

		=Memofile("mem_ppexp", 2) 
		thisform.cATALOG.text.Value=sav_nFilePath
		If Empty(thisform.Catalog.Text.Value)
				thisform.Catalog.Text.Value = "c:\"
			EndIf
	ENDPROC

		#ENDIF


	**
	PROCEDURE tbutton1.Click
		PRIVATE SAV_NFILEPATH
		SAV_NFILEPATH = THISFORM.CATALOG.TEXT.VALUE
		LOCAL C
		C = "sav_nFilePath"
		= MEMOFILE("mem_ppexp", 1, C)
		PAT.CPATH = SAV_NFILEPATH
		PAT.LYES = .T.
		THISFORM.RELEASE()
	ENDPROC
		**

		*--
		*-- ORIGINAL METHODS BELOW (inside #IF ... #ENDIF)
		*--
		#IF .F.
	PROCEDURE tbutton1.Click
		Private sav_nFilePath
		     sav_nFilePath     = thisform.Catalog.Text.Value
		     LOCAL c
		c="sav_nFilePath"
		=memofile("mem_ppexp",1,c)
		pat.cpath=sav_nFilePath
		pat.lYes=.T.
		thisform.Release()
	ENDPROC

		#ENDIF


	**
	PROCEDURE tbutton2.Click
		PRIVATE SAV_NFILEPATH
		SAV_NFILEPATH = THISFORM.CATALOG.TEXT.VALUE
		LOCAL C
		C = "sav_nFilePath"
		= MEMOFILE("mem_ppexp", 1, C)
		PAT.LYES = .F.
		THISFORM.RELEASE()
	ENDPROC
		**

		*--
		*-- ORIGINAL METHODS BELOW (inside #IF ... #ENDIF)
		*--
		#IF .F.
	PROCEDURE tbutton2.Click
		Private sav_nFilePath
		     sav_nFilePath     = thisform.Catalog.Text.Value
		     LOCAL c
		c="sav_nFilePath"
		=memofile("mem_ppexp",1,c)
		pat.lYes=.F.
		thisform.Release()
	ENDPROC

		#ENDIF


ENDDEFINE
*
*-- EndDefine: af_fygrbank
**************************************************
