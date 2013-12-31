name             'leeroy'
maintainer       'Needle Ops'
maintainer_email 'cookbooks@needle.com'
license          'Apache 2.0'
description      'Installs/Configures leeroy'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends          'python'
depends          'gunicorn'
depends          'runit'
