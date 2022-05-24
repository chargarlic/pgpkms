#!/bin/bash

python3 ./setup.py egg_info
pip install -r ./pgpkms.egg-info/requires.txt
