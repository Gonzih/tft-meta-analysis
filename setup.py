import setuptools

setuptools.setup(
  name="jupyter-pluto-proxy",
  packages=['plutoserver'],
  entry_points={
      'jupyter_serverproxy_servers': [
          # name = packagename:function_name
          'pluto = plutoserver:setup_plutoserver',
      ]
  },
  install_requires=['jupyter-server-proxy'],
)

import os
os.system('julia notebooks/src/pkgs.jl')
