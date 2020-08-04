SSEG SEGMENT PARA STACK 'STACK'
	DW 12 DUP(0)
SSEG ENDS

DSEG SEGMENT PARA 'DATA'
	dizi 		DW 100 DUP(0) ;dizinin boyutunun maks 100 olduğunu kabul ettik.
	FOUND		DB 0		  ;Üçgen eşitsizliğine uyup uymadığını bu değişkeni set ederek anlayacağız.
	tempCXVal	DW ?		  ;CX değişkenini geçici olarak tutacağımız değişken
	ILKDEGER    DW 1		  ;Bulduğumuz ilk değeri atayacağımız değişken
	IKINCIDEGER DW 1		  ;Bulduğumuz ikinci değeri atayacağımız değişken
	UCUNCUDEGER DW 1		  ;Bulduğumuz üçüncü değeri atayacağımız değişken
	tempVal		DW 1		  ;Bulunan üçüncü değeri bir register'a aktaracağımız değişken. 
							  ;Detaylı açıklaması ilerleyen satırlarda yapıldı.
	CR 			EQU 13		  
	LF 			EQU 10		  
	HT			EQU 9		  
	bosluk		DB ' ',0      ;Boşluk tanımlandı.
	nSayisiMSG 	DB 'dizinin n sayisini giriniz: ',0 									;Mesaj
	diziDegMSG 	DB 'dizi degerlerini giriniz', CR, LF,0 								;Mesaj
	diziBoyMSG	DB 'dizinin boyutunu veriniz: ',0										;Mesaj
	elGirMSG	DB '.elemani giriniz: ',0												;Mesaj
	hata1 		DB CR,LF,'Dikkat! Sayi girmediniz!!',CR,LF,0							;Mesaj
	hata2		DB 'Dikkat! Sayi 0 dan kucuk veya 1000 den buyuk olamaz!!',CR,LF,0		;Mesaj
	hata3 		DB 'n sayisi 3ten kucuk olamaz!',CR,LF,0								;Mesaj
	given_arr	DB CR,LF,'Girilen dizi:',CR,LF,0										;Mesaj
	sorted_arr	DB CR,LF,'Siralanmis dizi:',CR,LF,0										;Mesaj
	min_al_deg  DB CR,LF,'Minimum Alinabilecek Degerler',CR,LF,0						;Mesaj
	min_al_ilk  DB CR,LF,'Ilk Alinabilecek Deger:',CR,LF,0							 	;Mesaj
	min_al_iki  DB CR,LF,'Ikinci Alinabilecek Deger:',CR,LF,0						 	;Mesaj
	min_al_uc   DB CR,LF,'Ucuncu Alinabilecek Deger:',CR,LF,0						 	;Mesaj
	bitirme 	DB CR,LF,'Verilen dizide ucgen olusturabilecek eleman yok !',CR,LF,0 	;Mesaj
	count		DB 1 
	;"1. elemanı giriniz, 2. elemanı giriniz..." mesajlarındaki indisi tutacak olan eleman.
DSEG ENDS

CSEG SEGMENT PARA 'CODE'
	ASSUME CS:CSEG, DS: DSEG, SS: SSEG
ANA PROC FAR
		;
		PUSH DS
		XOR AX, AX
		PUSH AX
		;
		MOV AX, DSEG
		MOV DS, AX
		;	
		
		CALL READ_ARR 				;dizinin eleman sayisi ve dizi okunur.
		MOV AX,OFFSET given_arr		
		CALL PUT_STR				;nSayisiMSG'yi göster.
		CALL PRINT_ARR				;Sıralanmamış dizi bastırılır.
		
		CALL SORT					;diziyi sıralayan fonksiyonu çağırdık.
		
		CALL UCGENMI				;UCGENMI fonksiyonu çağırılır.
		
		CMP FOUND, 0				;Eğer dizide üçgen eşitsizliği formülü sağlanmıyorsa
		JE finish					;Aramaya devam et, sağlanıyorsa dur.
		
		MOV AX,OFFSET min_al_deg    
		CALL PUT_STR				;Minimum alınabilecek degerler.
		
		;İlk deger
		MOV AX,OFFSET min_al_ilk    
		CALL PUT_STR				;Yazı bastırılır.
		MOV AX, ILKDEGER			;Bulduğumuz ilkdeğeri AX registerına atadık.	
		CALL PUTN					;Ekrana yazdırdık.
		
		;İkinci deger
		MOV AX,OFFSET min_al_iki    
		CALL PUT_STR				;Yazı bastırılır.
		MOV AX, IKINCIDEGER			;Bulduğumuz ikincideğeri AX registerına atadık.
		CALL PUTN					;Ekrana yazdırdık.
		
		;Ucuncu deger
		MOV AX,OFFSET min_al_uc    
		CALL PUT_STR			    ;Yazı bastırılır.
		MOV AX, UCUNCUDEGER			;Bulduğumuz ucuncudeğeri AX registerına atadık.
		CALL PUTN					;Ekrana yazdırdık.
		
		JMP SON						
		;Üç değeri de bastırdıktan sonra SON'a atlar, programın çalışması tamamlanır.
		
finish:MOV AX,OFFSET bitirme    	;Verilen dizide ucgen olusturabilecek eleman yok.
		CALL PUT_STR				;Yazı bastırılır.
	SON:
		RETF
ANA  ENDP

;PUT_STR: Ekrana sonu 0 ile belirlenmiş dizgeyi yazdırır.
;PUTC   : AL'deki karakteri ekrana yazdırır.
;GETC   : Klavyeden basılan karakteri AL'ye alır.
;PUTN   : AX'deki sayıyı ekrana yazdırır.
;GETN   : Klavyeden okunan sayıyı AX'e koyar.

;Klavyeden basılan karakteri AL yazmacına alır ve ekranda gösterir.
;İşlem sonucunda sadece AL etkilenir.
GETC		PROC NEAR		
			MOV AH, 1H
			INT 21H
			RET
GETC		ENDP

;AL yazmacındaki değeri ekranda gösterir. 
;DL ve AH değişiyor. AX ve DX yazmaçlarının değerlerini korumak için PUSH/POP yapılır.
PUTC 		PROC NEAR
			PUSH AX
			PUSH DX
			MOV  DL, AL
			MOV  AH, 2
			INT  21H
			POP  DX
			POP  AX
			RET
PUTC 		ENDP

;Klavyeden basılan sayiyi okur, sonucu AX yazmacı üzerinden döndürür.
;DX: sayının işaretli olup olmadığını belirler
;BL: hane bilgisini tutar
;CX: okunan sayının islenmesi sırasındaki ara degeri tutar
;AL: klavyeden okunan karakteri tutar (ASCII), dizinin boyutu da burada tutulacaktır.
;AX: dönüş değeri olarak değişmek durumunda.
GETN 		PROC NEAR
			PUSH BX
			PUSH CX
			PUSH DX
GETN_START:	
			MOV DX, 1		;Sayının şimdilik + olduğunu varsayalım.
			XOR BX, BX		;Okuma yapmadı hane 0 olur.
			XOR CX, CX		;Ara toplam değeri de 0'dır.
NEW:		
			CALL GETC		;Klavyeden ilk değeri AL'ye oku.
			CMP  AL, CR	
			JE   FIN_READ	;Enter tuşuna basılmış ise okuma biter.
			CMP  AL, '-'	;Al, '-' mi geldi?
			JNE  CTRL_NUM	;Gelen 0-9 arasında bir sayı mı?
NEGATIVE:	
			MOV  DX, -1		;- basıldı ise sayı negatif, DX=-1 olur
			JMP  NEW		;yeni haneyi al
CTRL_NUM:	
			CMP  AL, '0'	;sayının 0-9 arasında olduğunu kontrol et.
			JB   ERROR
			CMP  AL, '9'
			JA   ERROR		;değil ise HATA mesajı verilecek
			SUB  AL, '0'	;rakam alındı, haneyi toplama dahil et.
			MOV  BL, AL		;BL'ye okunan haneyi koy
			MOV  AX, 10		;Haneyi eklerken *10 yapılacak
			PUSH DX			;MUL komutu DX'i bozar işaret için saklanmalı
			MUL  CX			;DX:AX = AX*CX
			POP  DX			;işareti geri al
			MOV  CX, AX		;CX'deki ara değer *10 yapıldı
			ADD  CX, BX		;okunan haneyi ara değere ekle
			JMP  NEW		;klavyeden yeni basılan değeri al
ERROR:		
			MOV  AX, OFFSET hata1
			CALL PUT_STR	;hata1 mesajını göster
			MOV  AL, count	;
			CBW
			CALL PUTN
			MOV  AX, OFFSET elGirMSG
			CALL PUT_STR		;elemanGir mesajını göster.
			JMP  GETN_START
FIN_READ:	
			MOV AX, CX			;sonuç AX üzerinden geri dönecek.
			CMP DX, 1			;İşarete göre sayıyı ayarlamak lazım.
			JE  FIN_GETN
			NEG AX				;AX=-AX
FIN_GETN: 	
			POP DX
			POP CX
			POP DX
			RET
GETN 		ENDP

PUTN 		PROC NEAR
;AX'de bulunan sayıyı onluk tabanda hane hane yazdırır.
;CX: haneleri 10'a bölerek bulacağız, CX=10 olacak
;DX: 32 bölmede işleme dahil olacak. Sonucu etkilemesin diye 0 olmalı.
			PUSH CX
			PUSH DX
			XOR  DX, DX			;DX 32 bit bölmede sonucu etkilemesin diye 0 olmalı
			PUSH DX				;haneleri ASCII karakter olarak yığında saklayacağız.
								;kaç haneyi alacağımızı bilmediğimiz için yığına 0 değeri koyup 
								;onu alana kadar devam edeceğiz
			MOV  CX, 10			;CX=10
			CMP  AX, 0
			JGE  CALC_DIGITS
			NEG  AX				;sayı negatif ise AX pozitif yapılır.
			PUSH AX				;AX sakla.
			MOV  AL, '-'		;işareti ekrana yazdır.
			CALL PUTC
			POP  AX				;AX'i geri al.
CALC_DIGITS:
			DIV  CX				;DX:AX=AX/CX, AX=bölüm DX=kalan
			ADD  DX, '0'		;kalan değerini ASCII olarak bul
			PUSH DX				;yığına sakla
			XOR  DX, DX			;DX=0
			CMP  AX, 0			;bölen 0 kaldı ise sayının işlenmesi bitti demek
			JNE  CALC_DIGITS	;işareti tekrarla
DISP_LOOP:	
								;yazılacak tüm haneler yığında. 
								;En anlamlı hane üstte en az anlamlı hane en altta
								;ve onun altında da sona vardığımızı anlamak için konan 0 değeri var.
			POP  AX				;Sırayla değerleri yığından alalım.
			CMP  AX, 0			;AX=0 olursa sona geldik demek
			JE   END_DISP_LOOP
			CALL PUTC			;AL'deki ASCII değeri yaz
			JMP  DISP_LOOP		;işleme devam
END_DISP_LOOP:
			POP DX
			POP CX
			RET
PUTN		ENDP

PUT_STR 	PROC NEAR
;AX'de adresi verilen sonunda 0 olan dizgeyi karakter karakter yazdırır. 
;BX dizgeye indis olarak kullanılır.
;Önceki değeri saklanmalıdır.
			PUSH BX				
			MOV BX, AX			 ;Adresi BX'e al
			MOV AL, BYTE PTR[BX] ;AL'de ilk karakter var
PUT_LOOP:	
			CMP  AL, 0			 
			JE   PUT_FIN		  ;0 geldi ise dizge sona erdi demek
			CALL PUTC			  ;AL'deki karakteri ekrana yazar
			INC  BX				  ;bir sonraki karaktere geç
			MOV  AL, BYTE PTR[BX] 
			JMP  PUT_LOOP		  ;yazdırmaya devam
PUT_FIN:	
			POP BX
			RET
PUT_STR 	ENDP

READ_ARR PROC NEAR				
;diziyi okuyoruz.
NDEGERIAL:	MOV AX, OFFSET diziBoyMSG ;'dizi boyutunu veriniz: ' 
			CALL PUT_STR		  	;Ekrana yazdırdı.
			CALL GETN			  	;GETN metodu ile dizi boyutu AL registerına aktarılır. 
									;Yordam çağırılır.
			CBW						;AH'da değer varsa 0 yapmak için AL'yi AX'e genişletiyorum. 
			CMP AX, 3				;dizinin boyutu 3'ten küçük olamaz! Kontrol ediyoruz.
			JAE DEVAM				;Boyutu 3'ten büyük ya da 3'e eşitse DEVAM.
			JL 	ERROR3				;Değilse hata!
DEVAM:   	MOV CX, AX 				;Alınan değer(AX) değeri CX'e atanır.
			MOV tempCXVal, AX		;AX değerini geçici olarak tempCXVal değerine atıyoruz.
			PUSH CX    				;CX'te eleman sayisi tutulur. 
									;Yordamların başında PUSH ve POP yapılarak değer korunur. 
			XOR DI, DI 				;DI dizi indisi olarak kullanılacaktır.	
ARR_LOOP:	MOV AL, count			;Her bir iterasyonda 'count. elemanı giriniz' 
									;metnini ekrana basmak için AL'ye count'u alıyorum. 
			CBW 					;convert byte to word, AL AX'e genişletilir
			CALL PUTN				;PUTN yordamı ile count'u ekrana yazdırdık.
			MOV AX, OFFSET elGirMSG ;'.elemani giriniz: '
			CALL PUT_STR			;Ekrana yazdırdı.
			CALL GETN				;dizinin ilgili elemanı klavyeden okunur.
			CMP AX, 1  				;1'den küçükse hata!
			JL ERROR2 				;Atla
			CMP AX, 1000			;1000'den büyükse hata!
			JG ERROR2   			;Atla
			INC count				;Sayı geçerli aralıktaysa count'u arttırıyorum. 
			MOV dizi[DI], AX        ;Alınan elemanı diziye atıyorum.
			ADD DI, 2				;İndisi ikişer arttırıyorum.
			LOOP ARR_LOOP			;ArrayLoop boyunca dön.
			JMP FIN_READ_ARR		;Döngü bittiğinde atla.
ERROR2:		MOV AX, OFFSET hata2	;'Dikkat! Sayi 0 dan kucuk veya 1000 den buyuk olamaz!!'
			CALL PUT_STR			;Ekrana yazdırdık.
			JMP ARR_LOOP			;ARR_LOOP'a geri döndü
ERROR3:		MOV AX, OFFSET hata3	;'n sayisi 3ten kucuk olamaz!'
			CALL PUT_STR			;Ekrana yazdırdık.
			JMP NDEGERIAL			;Başa geri dön.
FIN_READ_ARR:POP CX
			RET						;Return
READ_ARR ENDP

;diziyi bastırıyoruz.
PRINT_ARR	PROC NEAR
			PUSH CX					;CX değeri yığına atıldı.
			XOR DI, DI				;DI indisi sıfırlandı.
PUT_ARR:	MOV AX, dizi[DI]		;Örn. dizi[0]'yı AX'e atadık.
			CALL PUTN				;AX'teki sayıyı ekrana yazdırır.
			MOV AX,OFFSET bosluk	
			CALL PUT_STR			;Aralarında boşluk bırakarak diziyi yazdırıyoruz.			
			ADD DI, 2				;dizi word tanımlı olduğu için indis 2 artar.
			LOOP PUT_ARR			;PUT_ARR boyunca dön.
			POP CX					;CX değerini yığından al.
			RET						;Return
PRINT_ARR 	ENDP

;diziyi küçükten büyüğe sıraladığımız kısım.
SORT 		PROC NEAR
			;Değerlerin korunması için stack'e attık.
			PUSH SI
			PUSH CX
			PUSH DI
			PUSH AX
			PUSH BX
			PUSH DX
			;Dış çevrim işlemleri
			XOR SI, SI			;SI indisi sıfırlandı.
			MOV CX, CX  		
			DEC CX      		;CX=N-1
L2: 		MOV AX, dizi[SI]	;AX=dizi[0], AX küçük olan elemanı tutacak. 	
			MOV BX, SI			;BX=0, BX yer tutacak.	
			PUSH CX				;CX değerini yığına koyuyoruz.
			MOV DI, SI			;DI=0, SI=0
L1: 		ADD DI, 2			;Dizi word tanımlı, indisini ikişer arttırıyoruz.
			CMP AX, dizi[DI] 	;AX?dizi[2]
			JLE icdonus 		;dizi[0]<=dizi[2]
			MOV AX, dizi[DI] 	;AX=dizi[2]
			MOV BX, DI			;BX=2
icdonus: 	LOOP L1				;Devam.
			XCHG AX, dizi[SI] 	;Swap işlemi.
			MOV dizi[BX], AX 	;Bulunan küçük eleman dizinin ilgili yerine atanacak.
			POP CX				;CX değerini yığından alıyoruz.
			ADD SI, 2 			;dizi word tanımlandığı için indisi ikişer arttırıyoruz.
			LOOP L2	  			;L2'ye dön.
			;Değerler stack'ten geri alındı.
			POP DX
			POP BX
			POP AX
			POP DI
			POP CX
			POP SI
			;
SORT 		ENDP

;Sıralanmış dizide üçgen oluşturabilecek elemanları aradığımız kısım.
UCGENMI 	PROC NEAR
			;Değerlerin korunması için stack'e atadık.
			PUSH SI
			PUSH CX
			PUSH DI
			PUSH AX
			PUSH BX
			PUSH DX
			;
			XOR AX, AX			;AX registerını sıfırladık.
			MOV CX, tempCXVal	;tempCXVal'i CX'e atadık. 
								;tempCXVal değeri CX registerının içeriğini tutuyordu.
			SUB CX, 3			;CX'ten 3 çıkardık. 
								;İndisin, dizinin sondan üçüncü elemanına gelip gelmediğini 
								;kontrol ediyoruz.
			XOR SI, SI			;SI indisi (dizinin başlangıcını tutan indis) sıfırlandı.
DONGU:		CMP SI, CX			;SI indisi, dizinin sondan üçüncü elemanını göstermiyorsa 
								;diziyi taramaya devam eder.
			JA  SONN			;SI indisi, dizinin sondan üçüncü elemanını gösteriyorsa ve 
								;henüz üçgen eşitsizliğini sağlayabilecek değerleri bulamadıysa bitir.
			;diziyi WORD tanımladığımız için SI indisleri ikişer olarak artar.
			;Sıralanmış dizi için değerlerimiz: 1, 5, 7, 8 ...
			;İlk değerden itibaren registerlara atamaya başladık.
			MOV DX, dizi[SI]	;DX=1	
			MOV AX, dizi[SI+2]  ;AX=5
			MOV BX, dizi[SI+4]  ;BX=7
			;tempVal diye bir değişken tanımlanmıştı. 
			;Bu değişkendeki değer daha sonra bir register'a atanacak.
			MOV tempVal, BX		;tempVal=7
			ADD AX, BX		    ;AX=AX+BX --> AX=12
			CMP AX, DX			;12?1
			JA  CONTINUE		;Şartı kısmen sağladı.
			JMP FAIL		    ;Şartı sağlayamadı.
CONTINUE: 	SUB AX, BX			;AX=AX-BX --> AX=12-7=5
			SUB BX, AX			;BX=7 --> BX=BX-AX=2
			CMP	BX, DX		    ;2?1
			JB  SUCCESS			;Küçükse şart sağlandı. Büyük eşitse şartı sağlayamadı. FAIL çalışır.
FAIL:		ADD SI, 2		    ;SI indisinin değeri 2 arttırılır.		
			JMP DONGU		    ;diziyi taramaya devam et.
SUCCESS:	MOV FOUND, 1		;Bulundu.
			MOV ILKDEGER, 	 DX ;Bulunan kucuk deger ILKDEGER'e atanır.
			MOV IKINCIDEGER, AX	;Bulunan ikinci deger IKINCIDEGER'e atanır.
			MOV BX, tempVal		;tempVal'i BX register'ına atadık.
			MOV UCUNCUDEGER, BX	;Bulunan ucuncu deger UCUNCUDEGER'e atanır.
SONN:		;Biter.
			;Değerler stack'ten geri alındı.
			POP DX
			POP BX
			POP AX
			POP DI
			POP CX
			POP SI
			;
			RET 				;Return			
UCGENMI 	ENDP

CSEG ENDS
     END ANA