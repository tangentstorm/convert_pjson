NB. encode

fmtnum=: ,@('d<null>'&(8!:2))
fmtnums=: ' ' -.~ }.@,@(',' ,. >@{.@('d<null>'&(8!:1))@,.)
fmtint=: ,@('d<null>0'&(8!:2))
fmtints=: ' ' -.~ }.@,@(',' ,. >@{.@('d<null>0'&(8!:1))@,.)

sep=: }.@;@:(','&,each)
bc=: '{' , '}' ,~ ]
bk=: '[' , ']' ,~ ]

fixchar=: ]

ESC=: _2[\('\';'\\';CR;'\r';LF;'\n';TAB;'\t';(8{a.);'\b';FF;'\f';'"';'\"';'/';'\/')
decesc=: rplc&(1|."1 ESC)
encesc=: rplc&ESC
remq=: ]`(}.@}:)@.('"' = {.)
isboxed=: 0 < L.
ischar=: 2=3!:0
isfloat=: 8=3!:0
isscalar=: 0 = #@$
quotes=: '"'&,@(,&'"')

false=: 0
true=: 1

NB. this can be set by user
NULL=: 0

NB. =========================================================
cutcommas=: 3 : 0
y=. ',',y
m=. ~:/\y='"'
m=. *./ (m < y=','), 0 = _2 +/\ @ (-/)\ m <"1 '{}[]'=/y
m <@dltb;._1 y
)

NB. =========================================================
dec=: 3 : 0
r=. dec1 dltb ' ' (y I.@:e. TAB,CRLF)} y
NB. test for non-dictionary rank-2 boxed array
if. 1<L.r do.
  if. 1=#~.#&>r do.
    r0=. >{.,r
    if. -.(2=#$r0)*.(2={:$r0)*.(2=3!:0>{.,r0) do.
      r=. >r
    end.
  end.
end.
r
)

NB. =========================================================
dec1=: 3 : 0
if. 0=#y do. '' return. end.
if. y-:'null' do. NULL return. end.
select. {. y
case. '{' do. dec_object y
case. '[' do. dec_array y
case. '"' do. decesc }.}:y
case. do. dec_num y
end.
)

NB. =========================================================
dec_array=: 3 : 0
y=. dltb }.}:y
if. 0=#y do. $0 return. end.
if. -. y +./@:e. '"{[' do. ,dec_num y return. end.
dec1 each cutcommas y
)

NB. =========================================================
dec_num=: 3 : 0
nms=. ;: 'false true null'
res=. 0 ". ' ' (I.y=',')} y
if. -. 1 e. ,nms E.&> <y do. return. end.
nos=. <;._1 ',',y -. ' '
'f t n'=. nos&(I.@:= <) each nms
res=. true t} false f} res
if. #n do. NULL n} res end.
)

NB. =========================================================
dec_object=: 3 : 0
y=. }.}:y
if. 0=#y do. '' return. end.
dec_object1 &> a: -.~ cutcommas y
)

NB. =========================================================
dec_object1=: 3 : 0
n=. 1 i.~ (y=':') > ~:/\y='"'
k=. remq dltb n {. y
v=. dec1 dltb (n+1) }. y
k;<v
)

NB. =========================================================
enc=: 3 : 0
if. 1<#$y do.
  if. isboxed y do.
    if. (2 = #$y) do.
      if. (2 = {:$y) > 0 e. ischar &> {."1 y do.
        enc_dict y
      else.
        enc <"1 y   NB. non-dictionary rank-2 boxed array
      end.
    else.
      'rank>2 argument not supported' assert 2 = #$y
    end.
  else.
    bk sep <@enc"_1 y
  end.
elseif. isboxed y do.
  bk sep enc each y
elseif. ischar y do.
  enc_char y
elseif. isfloat y do.
  enc_num y
elseif. do.
  enc_int y
end.
)

NB. =========================================================
enc_char=: quotes @ encesc @ fixchar
enc_num=: bk @ fmtnums`fmtnum @. isscalar
enc_int=: bk @ fmtints`fmtint @. isscalar

NB. =========================================================
NB. enc_dict
NB. this encodes dicts where col 0 is char keys, and col 1 is values
enc_dict=: 3 : 0
'rank>2 argument not supported' assert 2 = #$y
'rank 2 argument must be a dictionary' assert (2 = {:$y) > 0 e. ischar &> {."1 y
key=. '"' ,each ({."1 y) ,each <'":'
val=. enc each {:"1 y
rep=. ;key,.val ,each <',',LF
bc LF,(_2}.rep),LF
)

NB. =========================================================
NB. finalize
NB. run customized code, if any

finalize_pjson_^:(3=(4!:0)@<) 'finalize_pjson_'

NB. =========================================================
cocurrent 'base'
