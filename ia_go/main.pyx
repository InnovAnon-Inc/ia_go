#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" Go Bindings """

import asyncio
import os
from pathlib                                 import Path
import subprocess
from typing                                  import List, Optional, Iterable
from typing                                  import ParamSpec

from structlog                               import get_logger

from ia_check_output.typ                     import Command
from ia_check_output.typ                     import Environment
from ia_check_output.main                    import acheck_output
from ia_check_output.main                    import acheck_output
from ia_pip.main                             import pip_install

P     :ParamSpec = ParamSpec('P')
logger           = get_logger()

##
#
##

def _go_install(
	*args          :P.args,
	**kwargs       :P.kwargs,
)->None:
	_args:List[str] = [ 'go', 'install',] # TODO
	_args.extend(args)
	env  :Environment   = dict(os.environ)
	env['PAGER']        = 'groff -Tutf8 -mandoc'
	return (_args, env,)

async def go_install(
	*args          :P.args,
	**kwargs       :P.kwargs,
)->None:
	cmd:Command
	env:Environment
	cmd, env = _go_install(*args, **kwargs,)
	await logger.ainfo('cmd: %s', cmd)
	return await acheck_output(cmd, env=env, universal_newlines=True, **kwargs,)

def append_ld_library_path()->bool:
	path:str = os.getenv('LD_LIBRARY_PATH', '')
	pathl:List[str] = os.pathsep.split(path)
	if ('.' in pathl):
		return False
	pathl.append('.')
	path = os.pathsep.join(pathl)
	os.environ['LD_LIBRARY_PATH'] = path
	return True

async def _main()->None:
	await pip_install('pybindgen', is_remote=True, is_requirements=False,)
	await go_install('golang.org/x/tools/cmd/goimports@latest')
	await go_install('github.com/go-python/gopy@latest')
	result:bool = append_ld_library_path()
	logger.info('LD_LIBRARY_PATH modified: %s', result,)

def main()->None:
	asyncio.run(_main())

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
