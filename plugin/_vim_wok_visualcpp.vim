" vim_wok_visualcpp.vim
" Some MS Visual Studio C++ like behavior for VIM
" MS & Visual Studio, Visual C++ (TM) by Microsoft Corp.
"
" * <Home>         toggles cursor pos between first-column and first-non-whitespace-column
" * <TAB>          indents current selected lines by one shiftwidth
" * <Shift>+<TAB>  un-indents current selected lines by one shiftwidth
"
" * <CTRL><F2>  Toggles an anonymous 'mark' on/off for the current line (uses named marks a-z)
" * <F2>        Jumps forward to the next anonymous mark
" * <SHIFT><F2> Jumps backward to the next anonymous mark
" * <CTRL><ALT><F2> Kills all Tags "a" - "z"
" 
" * <CTRL><SPACE>        Keyword/Functionname completion (forward)
" * <CTRL><SHIFT><SPACE> Keyword/Functionname completion (backward)
"
"
" Wolfram 'Der WOK' Esser, 2001-08-21
" mailto:wolfram@derwok.de
" http://www.derwok.de
"
" Version 0.1, 2001-08-21 - initial release



" The Keymappings ---------------------------------------------------------------------
" WOK: Visual C++ like Home 
" (jumps between 1.column / 1. non-whitespace-char of line)
map <Home> :call HomeWok()<cr>
map! <Home> <C-o>:call HomeWok()<cr>

" WOK: Visual C++ like TAB 
" (indent/unindent block in visual/select mode with TAB: keeps last selection!)
vmap <TAB> :><cr>gv
vmap <S-TAB> :<<cr>gv

" WOK: CTRL-SPACE: keyword completion, like in Visual C++
map  <C-space> <C-n>
map!  <C-space> <C-n>
map  <C-S-space> <C-p>
map!  <C-S-space> <C-p>

" WOK: <CTRL><SHIFT><TAB> switches to previous buffer, like MS Visual C++
map! <C-S-TAB> <C-o>:bN<CR>
:map  <C-S-TAB> :bN<CR>

" WOK: Visual C++ like F2/Shift-F2/CTRL-F2
" (jumps forward/backward and toggle 'anonymous' marks for lines (by using marks a-z))
" use CTRL-F2 to set/unset anonymous marks on current line
map <S-f2> :call PrevMarkWok()<cr>
map! <S-f2> <C-o>:call PrevMarkWok()<cr>
map <f2> :call NextMarkWok()<cr>
map! <f2> <C-o>:call NextMarkWok()<cr>
map <C-f2> :call ToggleMarkWok()<cr>
map! <C-f2> <C-o>:call ToggleMarkWok()<cr>
map <C-M-f2> :call KillAllMarksWok()<cr>
map! <C-M-f2> <C-o>:call KillAllMarksWok()<cr>



" The Subfunctions ---------------------------------------------------------------------
" WOK: 2001-06-04
" <Home> toggles cursor pos between first-column and first-non-whitespace-column
func! HomeWok()
	" get current column...
	let oldcol = col(".")
	" go to first non-white
	normal ^
	" in what column are we now?
	let newcol = col(".")
	" not moved (so we already where at first-non-white)?
	if (oldcol == newcol)
		normal $
		let lastcol = col(".")
		if (newcol == lastcol)
			" workaround: append one space, when line has only 1 char
			normal a 0
		else
			" go to column '1'
			normal 0
		endif
	" we did move - but forward...
	elseif ((oldcol != 1) && (newcol > oldcol))
		" go to column '1'
		normal 0
	endif
endfunc



" WOK: 2001-06-08
" simulates anonymous marks with named marks "a-z"
" Adds/Deletes 'anonymous' Mark on current line
func! ToggleMarkWok()

	let curline = line(".")
	let freemark = ""
	let foundfree = 0

	" suchen, ob Zeile ein Mark hat, wenn ja, alle sammeln in killmarks!
	let killmarks = ""
	let killflag = 0
	let i = 97
	while i < 123
		let m = nr2char(i)
		let ml = line("'".m)
		if (ml == curline)
			let killmarks = killmarks."m".m
			let killflag = 1
  		endif
		
		let i = i +1
	endwhile

	if (killflag)
		" alte Mark(s) löschen??
 		echo "KILLMARKS: '".killmarks."'"
		normal o
		exec "normal ".killmarks."<CR>"
		normal dd
		normal 0
		normal k 
	else
		" oder neues Mark einfügen?
		let i = 97
		while i < 123
			" erstes freies suchen...
			let m = nr2char(i)
			let ml = line("'".m)
			if(ml == 0)
				let freemark = m
				let foundfree = 1
				let i =130
	  		endif
			 
			let i = i +1
		endwhile
	 
		if (foundfree)
			echo "NEWMARK: '".freemark."'"
			exec "normal m".freemark."<CR>"
		endif
	endif
endfunc



" WOK: 2001-06-08
" simulates anonymous marks with named marks "a-z"
" Jumps to first Preceding Mark before current cursor
" Wraps at top of file
func! PrevMarkWok()

	let curline = line(".")
	let prevmark = -1
	let lastmark = -1
	
	let i = 97
	while i < 123
		let m = nr2char(i)
		let ml = line("'".m)
		if(ml != 0)
			if (ml < curline && ml > prevmark)
				let prevmark = ml
			endif
			if (ml > lastmark)
				let lastmark = ml
			endif
  		endif
		
		let i = i +1
	endwhile


	if (prevmark != -1)
		exec "normal ".prevmark."G<CR>"
		normal 0
	elseif (lastmark != -1)
		exec "normal ".lastmark."G<CR>"
		normal 0
		echo "WRAP TO LAST MARK"
	else
		echo "SORRY, NO MARKS (set with CTRL-F2)"
	endif
endfunc



" WOK: 2001-06-08
" simulates anonymous marks with named marks "a-z"
" Jumps to next following mark after current cursor
" Wraps at bottom of file
func! NextMarkWok()

	let curline = line(".")
	let nextmark = 99999999
	let firstmark =99999999
	
	let i = 97
	while i < 123
		let m = nr2char(i)
		let ml = line("'".m)
		if(ml != 0)
			if (ml > curline && ml < nextmark)
				let nextmark = ml
			endif
			if (ml < firstmark)
				let firstmark = ml
			endif
  		endif
		
		let i = i +1
	endwhile


	if (nextmark != 99999999)
		exec "normal ".nextmark."G<CR>"
		normal 0
	elseif (firstmark != 99999999)
		exec "normal ".firstmark."G<CR>"
		normal 0
		echo "WRAP TO FIRST MARK"
	else
		echo "SORRY, NO MARKS (set with CTRL-F2)"
	endif
endfunc



" WOK: 2001-06-08
" simulates anonymous marks with named marks "a-z"
" removes all marks "a" - "z"
func! KillAllMarksWok()
	let killmarks = ""
	let killflag = 0
	let i = 97
 
	while i < 123
		let m = nr2char(i)
		let ml = line("'".m)
		" ex. dieses Mark?
		if (ml != 0)
			let killmarks = killmarks."m".m
			let killflag = 1
  		endif
		
		let i = i +1
	endwhile

	if (killflag)
		" alte Mark(s) löschen
 		echo "KILL ALL MARKS IN FILE: '".killmarks."'"
		normal o
		exec "normal ".killmarks."<CR>"
		normal dd
		normal 0
		normal k 
	endif
endfunc

