function! docker_tools#container#config() abort
	return s:config
endfunction

let s:config = {
	\'start': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Starting container'},
	\'stop': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Stopping container'},
	\'rm': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Removing container'},
	\'restart': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Restarting container'},
	\'pause': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Pausing container'},
	\'unpause': {
		\'mode': 'execute',
		\'type': 'normal',
		\'msg': 'Unpausing container'},
	\'exec': {
		\'mode': 'interactive',
		\'type': 'input',
		\'options': '-it',
		\'args': {
			\'input_msg': 'Enter command: '}
		\},
	\'logs': {
		\'mode': 'export',
		\'type': 'normal'}
\}

function s:config.exec.args.Input_fn(response) abort dict
	let self.command = printf("%s %s",self.command,a:response)
endfunction

function! docker_tools#container#mapping() abort
	return s:mapping
endfunction

let s:mapping = {
	\'start':'s',
	\'stop':'d',
	\'restart':'r',
	\'rm':'x',
	\'pause':'p',
	\'unpause':'u',
	\'exec':'>',
	\'logs':'<'
\}

function! docker_tools#container#help(mapping) abort
	let l:help = printf("# %s: start container\n",a:mapping['start'])
	let l:help .= printf("# %s: stop container\n",a:mapping['stop'])
	let l:help .= printf("# %s: restart container\n",a:mapping['restart'])
	let l:help .= printf("# %s: delete container\n",a:mapping['rm'])
	let l:help .= printf("# %s: pause container\n",a:mapping['pause'])
	let l:help .= printf("# %s: unpause container\n",a:mapping['unpause'])
	let l:help .= printf("# %s: execute command to container\n",a:mapping['exec'])
	let l:help .= printf("# %s: show container logs\n",a:mapping['logs'])
	return help
endfunction
