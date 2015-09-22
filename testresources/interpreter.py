from os.path import abspath, dirname, join, normpath
import os
import subprocess
import sys


def get_variables(path, name=None, version=None):
    return {'INTERPRETER': InterpreterFactory(path, name, version)}


def InterpreterFactory(path, name=None, version=None):
    if path.endswith('.jar'):
        return StandaloneInterpreter(path, name, version)
    return Interpreter(path, name, version)


class Interpreter(object):

    def __init__(self, path, name=None, version=None):
        self.path = path
        if not name:
            name, version = self._get_name_and_version(path)
        self.name = name
        self.version = version
        self._robot_path = normpath(join(dirname(abspath(__file__)),
                                         '..', 'src', 'robot'))

    def _get_name_and_version(self, path):
        try:
            output = subprocess.check_output([path, '-V'],
                                             stderr=subprocess.STDOUT)
        except OSError:
            raise ValueError('Invalid interpreter: %s' % path)
        name, version = output.split()[:2]
        version = '.'.join(version.split('.')[:2])
        return name, version

    @property
    def excludes(self):
        if self.is_python and self.version == '2.6':
            yield 'no-python26'
            yield 'require-et13'
        if self.is_jython:
            yield 'no-jython'
            yield 'require-lxml'
        else:
            yield 'require-jython'
        if self.is_ironpython:
            yield 'no-ipy'
            yield 'require-et13'
            yield 'require-lxml'
            yield 'require-docutils'  # https://github.com/IronLanguages/main/issues/1230
        for exclude in self._os_excludes:
            yield exclude

    @property
    def _os_excludes(self):
        if self.is_windows:
            yield 'no-windows'
            if self.is_jython:
                yield 'no-windows-jython'
            if self.is_python and self.version == '2.6':
                yield 'no-windows-python26'
        if not self.is_windows:
            yield 'require-windows'
        if self.is_osx:
            yield 'no-osx'
            if self.is_python:
                yield 'no-osx-python'

    @property
    def is_python(self):
        return self.name == 'Python'

    @property
    def is_jython(self):
        return self.name == 'Jython'

    @property
    def is_ironpython(self):
        return self.name == 'IronPython'

    @property
    def is_linux(self):
        return 'linux' in sys.platform

    @property
    def is_osx(self):
        return sys.platform == 'darwin'

    @property
    def is_windows(self):
        return os.name == 'nt'

    @property
    def os(self):
        for condition, name in [(self.is_linux, 'Linux'),
                                (self.is_osx, 'OS X'),
                                (self.is_windows, 'Windows')]:
            if condition:
                return name
        return sys.platform


    # FIXME: Properties below should return a list of arguments that is
    # executed with Run Process

    @property
    def runner(self):
        return '%s %s' % (self.path, join(self._robot_path, 'run.py'))

    @property
    def rebot(self):
        return '%s %s' % (self.path, join(self._robot_path, 'rebot.py'))

    @property
    def libdoc(self):
        return '%s %s' % (self.path, join(self._robot_path, 'libdoc.py'))

    @property
    def testdoc(self):
        return '%s %s' % (self.path, join(self._robot_path, 'testdoc.py'))

    @property
    def tidy(self):
        return '%s %s' % (self.path, join(self._robot_path, 'tidy.py'))


class StandaloneInterpreter(Interpreter):

    def __init__(self, path, name=None, version=None):
        Interpreter.__init__(self, abspath(path), name or 'Standalone JAR',
                          version or '2.7')
        self._bootclasspath = self._get_bootclasspath()

    def _get_bootclasspath(self):
        classpath = os.environ.get('CLASSPATH')
        if classpath:
            return '-Xbootclasspath/a:%s' % classpath
        return ''

    @property
    def excludes(self):
        for exclude in ['no-standalone', 'no-jython', 'require-lxml',
                        'require-docutils', 'require-yaml']:
            yield exclude
        for exclude in self._os_excludes:
            yield exclude

    @property
    def is_python(self):
        return False

    @property
    def is_jython(self):
        return True

    @property
    def is_ironpython(self):
        return False


    # FIXME: Properties below should return a list of arguments that is
    # executed with Run Process

    @property
    def runner(self):
        return 'java %s -jar %s' % (self._bootclasspath, self.path)

    @property
    def rebot(self):
        return 'java %s -jar %s rebot' % (self._bootclasspath, self.path)

    @property
    def libdoc(self):
        return 'java %s -jar %s libdoc' % (self._bootclasspath, self.path)

    @property
    def testdoc(self):
        return 'java %s -jar %s testdoc' % (self._bootclasspath, self.path)

    @property
    def tidy(self):
        return 'java %s -jar %s tidy' % (self._bootclasspath, self.path)
