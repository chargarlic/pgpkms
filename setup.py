#!/usr/bin/env python

from setuptools import setup

params = {
  'name': 'pgpkms',
  'version': '1.0.0',
  'description': 'PGP signatures with AWS KMS keys',
  'long_description': 'Use AWS KMS keys to generate GnuPG/OpenPGP compatible signatures',
  'maintainer': 'Juit Developers <developers@juit.com>',
  'author': 'Juit Developers',
  'author_email': 'developers@juit.com',
  'url': 'https://github.com/juitnow/pgpkms',
  'platforms': ['any'],
  'license': 'Apache-2',
  'packages': [ 'pgpkms' ],
  'python_requires': '>=3.5'
}

if __name__ == "__main__":
  setup(**params)
