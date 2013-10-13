**************************************************
*-- Class:        memconf 
*-- ParentClass:  custom
*-- BaseClass:    custom
*-- Time Stamp:   10/13/13 02:50:04 PM
*-- Класс для сохраненеия и извлечения значений переменных в таблицу Config по подобию функции MEMOFILE", поддерживает массивы
*
DEFINE CLASS memconf AS custom


	Comment = "Класс для сохраненеия и извлечения значений переменных в таблицу Config по подобию функции MEMOFILE"
	domdocument = .NULL.
	Name = "memconf"


	*-- Сохраняет значения переменных
	PROCEDURE savevalues
		LPARAMETERS cName, cVars
		IF EMPTY(cVars)
			RETURN 
		ENDIF 
		*LOCAL ox as MSXML2.DOMDocument 
		this.domdocument.loadXML('<?xml version="1.0" encoding="UTF-8"?><variables></variables>')
		LOCAL oVar as MSXML2.IXMLDOMElement, oEl as MSXML2.IXMLDOMElement 
		LOCAL I, cVar, J, K, cTmp
		FOR I = 1 TO GETWORDCOUNT(cVars, ";")
			cVar = GETWORDNUM(cVars, i, ';')
			oVar = this.domdocument.createElement('variable')
			oVar.setAttribute('name', cVar)
			oVar.setAttribute('type', this.vartype(cVar))
			IF oVAr.getAttribute('type') == 'A'
				oVar.setAttribute('rows', ALEN(&cVar,1))
				IF ALEN(&cVar, 2) > 0
					oVar.setAttribute('columns', ALEN(&cVar, 2))
				ENDIF 
				FOR J = 1 TO ALEN(&cVAr, 1)
					oEl = this.domdocument.createElement('item')
					oel.setAttribute('row', J)
					IF ALEN(&cVar, 2) > 0
						oEl.setAttribute('column', 1)
						cTmp = cVar + '[' + ALLTRIM(STR(J)) + ', 1]'
					ELSE 
						cTmp = cVar + '[' + ALLTRIM(STR(J)) + ']'
					ENDIF 
					oEl.setAttribute('type') = VARTYPE(&cTmp)
					oEl.nodeTypedValue = &cTmp
					oVar.appendChild(oEl)
					FOR K = 2 TO ALEN(&cVar, 2)
						oEl = this.domdocument.createElement('item')
						oel.setAttribute('row', J)
						oEl.setAttribute('column', K)
						cTmp = cVar + '[' + ALLTRIM(STR(J)) + ',' + STR(K) + ']'
						oEl.setAttribute('type') = VARTYPE(&cTmp)
						oEl.nodeTypedValue = &cTmp
						oVar.appendChild(oEl)
					NEXT 
				NEXT
			ELSE 
				ovar.nodeTypedValue = &cVar 
			ENDIF 

			this.domdocument.documentElement.appendChild(oVar)
		NEXT 
		*oConfig.setvalue(cName, this.domdocument.xml)
		*oConfig.saveall()
	ENDPROC


	*-- Извлекает значения переменных
	PROCEDURE getvalues
		LPARAMETERS cName
		local cVal
		cVal = oConfig.GetValue(cName)
		if EMPTY(cVal)
			retu 
		ENDIF 

		LOCAL oVar as MSXML2.IXMLDOMElement, oItem as MSXML2.IXMLDOMElement 


		this.domdocument.loadXML(cVal)
		local I, cVar, cTmp, J, K

		LOCAL oList as MSXML2.IXMLDOMNodeList

		oList = this.domdocument.selectNodes('//variable')

		IF oList.length < 1
			RETURN 
		ENDIF 
		FOR i = 0 TO oList.length-1
			oVar = oList.item(i)
			IF oVar.getAttribute('type') == 'A'
				cTmp = cName + '[' + oVar.getAttribute('rows')
				IF !ISNULL(oVar.getAttribute('columns'))
					cTmp = cTmp + ', ' + oVar.getAttribute('columns')
				ENDIF 
				cTmp = 'DIMENSION ' + cTmp + ']'
				&cTmp
				FOR J = 1 TO VAL(oVar.getAttribute('rows'))
					IF ISNULL(oVar.getAttribute('columns'))
						cTmp = cName + '[' + ALLTRIM(STR(J)) + ']'
						oItem = oVar.selectSingleNode('//item[@row="'+ALLTRIM(STR(J))+'"]')
						&cTmp = this.gettypedval(oItem.getAttribute('type'), oItem.nodeTypedValue)
					ELSE
						FOR K = 1 TO VAL(oVar.getAttribute('columns'))
							cTmp = cName + '[' + ALLTRIM(STR(J)) + ', ' + ALLTRIM(STR(K)) + ']'
							oItem = oVar.selectSingleNode('//item[@row="'+ALLTRIM(STR(J))+'" and @column="'+ALLTRIM(STR(K))+'"]')
							&cTmp = this.gettypedval(oItem.getAttribute('type'), oItem.nodeTypedValue)
						NEXT 
					ENDIF 
				NEXT 
			ELSE
				cVar = ovar.getAttribute('name')
				&cVar = this.gettypedval(oVar.getAttribute('type'), oVar.nodeTypedValue)
			ENDIF 
		NEXT 
	ENDPROC


	PROCEDURE gettypedval
		LPARAMETERS cType, cVal
		DO CASE 
			CASE cType == "C"
				RETURN cVal
			CASE cType == "N"
				RETURN VAL(cVal)
			CASE cType == "L"
				RETURN &cVal
			CASE cType == "D"
				RETURN CTOD(cVal)
		ENDCASE 

		RETURN &cVal
	ENDPROC


	PROCEDURE memofile
		LPARAMETERS cName, nType, cVars
		IF nType == 1
			this.savevalues(cName, cVars)
		ENDIF 
		IF nType == 2
			this.getvalues(cName)
		ENDIF 
	ENDPROC


	PROCEDURE vartype
		LPARAMETERS mVal
		LOCAL cType, oEx as Exception, nLen
		TRY
			nLen = ALEN(&mVal)
		CATCH TO oEx
		ENDTRY 

		IF VARTYPE(oEx) == 'O' OR EMPTY(nLen)
			RETURN VARTYPE(&mVal)

		ENDIF 

		RETURN 'A'
	ENDPROC


	PROCEDURE Init
		this.domdocument = CREATEOBJECT("msxml2.DOMDocument")
	ENDPROC


ENDDEFINE
*
*-- EndDefine: memconf
**************************************************
