#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2016, Mike Fennemore <mike.fennemore@sentia.com>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_chocolatey
version_added: "1.9"
short_description: Adds,deletes and performs power functions on Hyper-V VM's.
description:
    - Installs packages using Chocolatey (http://chocolatey.org/). If Chocolatey is missing from the system, the module will install it. List of packages can be found at http://chocolatey.org/packages
options:
  name:
    description:
      - Name of VM
    required: true
  state:
    description:
      - State of VM
    required: false
    choices:
      - present
      - absent
	  - restart
	  - shutdown
	  - start
    default: present
  memory:
    description:
      - Sets the amount of memory for the VM.
    required: false
    default: 512MB
  hostserver:
    description:
      - Server to host VM
    required: false
    default: null
  generation:
    description:
      - Specifies the generation of the VM
    required: false
    default: 2
  diskpath:
    description:
      - Specify path of VHD/VHDX file for VM
	  - If the file exists it will be attached, if not then a new one will be created
    require: false
    default: null
    version_added: '2.1'
author: "Mike Fennemore (@mikef_sa)"
'''

# TODO:
# * Better parsing when a package has dependencies - currently fails
# * Time each item that is run
# * Support 'changed' with gems - would require shelling out to `gem list` first and parsing, kinda defeating the point of using chocolatey.

EXAMPLES = '''
  # Create VM
  hyperv_guest:
    name: Test

  # Delete a VM
  hyperv_guest:
    name: Test
	state: absent

  # Create VM with 512MB memory
  hyperv_guest:
    name: Test
	memory: 512MB

  # Install git from specified repository
  win_chocolatey:
    name: git
    source: https://someserver/api/v2/
'''
