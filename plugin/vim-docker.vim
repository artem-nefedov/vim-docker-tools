let g:vdocker_splitsize = 20

command! OpenVDSplit :call OpenVDSplit()
command! CloseVDSplit :call CloseVDSplit()
command! ToggleVDSplit :call ToggleVDSplit()
command! VDRunCommand :call VDRunCommand()

function! SetKeyMapping()
		nnoremap <buffer> <silent> q :CloseVDSplit<CR>
		nnoremap <buffer> <silent> s :call VDContainerAction('start')<CR>
		nnoremap <buffer> <silent> d :call VDContainerAction('stop')<CR>
		nnoremap <buffer> <silent> x :call VDContainerAction('rm')<CR>
		nnoremap <buffer> <silent> r :call VDContainerAction('restart')<CR>
		nnoremap <buffer> <silent> > :call VDExec('sh')<CR>
		nnoremap <buffer> <silent> < :call VDRunCommand()<CR>
endfunction

function! OpenVDSplit()
	if !exists('g:vdocker_windowid')
		silent execute "leftabove ".g:vdocker_splitsize."split DOCKER"
		setlocal buftype=nofile
		setlocal cursorline
		call LoadDockerPS()
		normal! 2G
		setlocal nobuflisted
		let g:vdocker_windowid = win_getid()
		autocmd BufWinLeave <buffer> call LeaveVDSplit()
		call SetKeyMapping()
	else
		call win_gotoid(g:vdocker_windowid)
	endif
endfunction

function! CloseVDSplit()
	if exists('g:vdocker_windowid')
		call win_gotoid(g:vdocker_windowid)
		quit
	endif
endfunction

function! ToggleVDSplit()
	if !exists('g:vdocker_windowid')
		call OpenVDSplit()
	else
		call CloseVDSplit()
	endif
endfunction

function! LeaveVDSplit()
	if exists('g:vdocker_windowid')
		unlet g:vdocker_windowid
	endif
endfunction

function! LoadDockerPS()
	setlocal modifiable
	let a:save_cursor = getcurpos()
	normal! ggdG
	silent! read ! docker ps -a
	normal! 1Gdd
	call setpos('.', a:save_cursor)
	setlocal nomodifiable
endfunction

function! RefreshPanel(timerId)
	call LoadDockerPS()
endfunction

function! FindContainerID()
	let a:row_num = getcurpos()[1]
	if a:row_num ==# 1
		return
	endif
	call search("CONTAINER ID")
	let a:current_cursor = getcurpos()
	if a:current_cursor[1] !=# 1
		echoerr "No container ID found"
		return
	endif
	let a:current_cursor[1] = a:row_num
	call setpos('.', a:current_cursor)
	return expand('<cWORD>')
endfunction

function! ContainerAction(action,dockerid)
	call EchoContainerActionMessage(a:action,a:dockerid)
	if has('nvim')
		call jobstart('docker container '.a:action.' '.a:dockerid,{'on_stdout': 'ActionCallBack','on_stderr': 'ErrCallBack'})
	elseif has('job')
		call job_start('docker container '.a:action.' '.a:dockerid,{'out_cb': 'ActionCallBack','err_cb': 'ErrCallBack'})
	else
		call system('docker container '.a:action.' '.shellescape(a:dockerid))
	endif
endfunction

function! EchoContainerActionMessage(action,dockerid)
	if a:action=='start'
		echo 'Starting container '.a:dockerid.'...'
	elseif a:action=='stop'
		echo 'Stopping container '.a:dockerid.'...'
	elseif a:action=='rm'
		echo 'Removing container '.a:dockerid.'...'
	elseif a:action=='restart'
		echo 'Restarting container '.a:dockerid.'...'
	endif
endfunction

function! ActionCallBack(...)
	if exists('g:vdocker_windowid')
		let a:current_windowid = win_getid()
		call win_gotoid(g:vdocker_windowid)
		call LoadDockerPS()
		call win_gotoid(a:current_windowid)
		if has('nvim')
			redraw | echo a:2[0]
		else
			redraw | echo a:2
		endif
	endif
endfunction

function! ErrCallBack(...)
	if has('nvim')
		redraw | echoerr a:2[0]
	else
		redraw | echoerr a:2
	endif
endfunction

function! VDContainerAction(action)
	call ContainerAction(a:action,FindContainerID())
endfunction

function! TerminalCommand(command,termname)
	if has('nvim')
		silent execute "leftabove split TERM"
		call termopen(a:command)
	elseif has('terminal')
		call term_start(a:command,{"term_finish":"close","term_name":a:termname})
	else
		echoerr 'terminal mode is not supported'
	endif
endfunction

function! VDExec(command)
	call TerminalCommand('docker exec -ti '.FindContainerID().' sh -c "'.a:command.'"',FindContainerID())
endfunction

function! VDRunCommand()
	let command = input('Enter command: ')
	call VDExec(command)
endfunction
