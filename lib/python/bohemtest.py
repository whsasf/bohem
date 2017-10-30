"""A module for helper functions when writing tests in Python for Bohem.
   do 'from bohemtest import *' to import all of the environment variables, they will be prepended with a _ to avoid name collisions
   For example if you want to access the environment variable TC_NAME, refer to it as _TC_NAME in the scripts."""

import os
import time
import sys
import atexit
import subprocess
import random
import string

try:
	from exceptions import NameError, EnvironmentError
except:
	pass


class Bunch(object):
  def __init__(self, adict):
    self.__dict__.update(adict)


def done():
	try:
		sys.exit(_return_code)
	except NameError:
		print('Test script did not indicate any outcome, bohem should detect this.')
		sys.exit(1)


def run_script(command):
    """Runs a shell command.
    Example run_script('log_fail') or run_script('rg_create_domain testdomain')"""
    try:
    	p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE, shell=True)
    except OSError:
        p = subprocess.Popen(['bash', '-c'] + command.split())

    out, err = p.communicate()
    sys.stdout.write(out)

    return p.returncode, out, err


def random_word():
	try:
		words = open('/usr/share/dict/words').read().splitlines()
	except EnvironmentError:
		try:
			words = open('/usr/dict/words').read().splitlines()
		except EnvironmentError:
			return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(6))

	return ''.join(x for x in random.choice(words) if x.isalnum())


def rg_install_check():
	if not rg_installed():
		print("RG isn't installed/RG_SMTP1_HOST isn't set")
		log_skip()
		sys.exit(1)


def rg_installed():
	if _RG_SMTP1_HOST == "" or _RG_SMTP1_HOST == 'nohost.invalid':
		return False
	else:
		return True



def log_warning(msg=""):
	print('{0}WARNING: {1}: Something bad happened. {2}'.format(__bohem_log_prefix, _TC_NAME, msg))


def log_pass(msg=""):
        print('{0}PASSED: {1}: Test passed.{2}({3} sec.)'.format(__bohem_log_prefix, _TC_NAME, msg, int(time.time() - _start_time)))
	global _return_code
	_return_code = 0


def log_fail(msg=""):
        print('{0}FAILED: {1}: Test failed.{2}({3} sec.)'.format(__bohem_log_prefix, _TC_NAME, msg, int(time.time() - _start_time)))
	global _return_code
	_return_code = 1


def log_skip(msg=""):
        print('{0}SKIPPED: {1}: Test skipped.{2}({3} sec.)'.format(__bohem_log_prefix, _TC_NAME, msg, int(time.time() - _start_time)))
	global _return_code
	_return_code = 0

def log_broken(msg=""):
	print('{0}BROKEN: {1}: Test skipped.{2}({3} sec.)'.format(__bohem_log_prefix, _TC_NAME, msg, int(time.time() - _start_time)))
	global _return_code
	_return_code = 1

env = Bunch(os.environ.copy())

newenv = {}
for k, v in os.environ.copy().items():
        newenv['_' + k] = v


locals().update(newenv)

_start_time = time.time()
atexit.register(done)

