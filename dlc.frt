: IMMEDIATE
	last_word_addr @
	cfa 1 -
	dup c@
	1 or swap c!
;

: if
	' branch0 ,
	here_addr 0 ,
;
IMMEDIATE

: else
	' branch ,
	here_addr 0 ,
	swap here_addr swap !
;
IMMEDIATE

: then
	here_addr swap !
;
IMMEDIATE	

: repeat 
	here_addr
;
IMMEDIATE

: until
	' branch0 ,
	,
;
IMMEDIATE

: for
	here_addr
;
IMMEDIATE

: endcond
	' branch0 ,
	here_addr 0 ,
	' branch ,
	here_addr 0 ,
	rot here_addr
;
IMMEDIATE

: endloop
	' branch ,
	swap here_addr 0 , !	
	rot rot
	here_addr swap !
;
IMMEDIATE

: endfor
	' branch ,
	swap here_addr 0 , !
	here_addr swap !
;
IMMEDIATE

: for-value
	' >r ,
	' lit , 0 ,
	' >r ,
	' for execute
		' r> ,
		' dup ,
		' r> ,
		' dup ,
		' >r ,
		' swap ,
		' >r ,
		' < ,
 		' endcond execute
		
		' r> ,
		' lit , 1 ,
		' + ,
		' >r ,
	 	' endloop execute
;
IMMEDIATE

: endfor-value
	' endfor execute
	' r> ,
	' r> ,
	' drop ,
	' drop ,
;
IMMEDIATE
