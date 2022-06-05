import setuptools

setuptools.setup(
  name="jupyter-pluto-proxy",
  py_modules=['plutoserver'],
  entry_points={
      'jupyter_serverproxy_servers': [
          # name = packagename:function_name
          'pluto = plutoserver:setup_plutoserver',
      ]
  },
  install_requires=['jupyter-server-proxy @ git+http://github.com/fonsp/tft-meta-analysis@6439f3f8ffbcae25a93e17eef8ea44eb9b1b20dd'],
)

import os
os.system('julia notebooks/src/pkgs.jl')
