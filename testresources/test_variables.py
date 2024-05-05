from datetime import datetime, timedelta
from os.path import abspath, dirname, join, normpath

__all__ = ['DATADIR', 'SYSTEM_ENCODING', 'datetime', 'timedelta']

DATADIR = normpath(join(dirname(abspath(__file__)), '..', 'testdata'))
