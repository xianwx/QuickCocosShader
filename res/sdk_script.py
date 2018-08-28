#coding:utf-8
import os
import os.path
from xml.etree import ElementTree as ET
from xml.etree.ElementTree import SubElement
from xml.etree.ElementTree import Element
from xml.etree.ElementTree import ElementTree
import zipfile
import re
import subprocess
import platform
from xml.dom import minidom
import codecs
import sys

androidNS = 'http://schemas.android.com/apk/res/android'

sync_adapter = 'qihoo_game_sdk_sync_adapter.xml'
ET.register_namespace('android', androidNS)
adapterTree = ET.parse(sync_adapter)
adapterRoot = adapterTree.getroot()
contentAuthority = '{' + androidNS + '}contentAuthority'
adapterRoot.set(contentAuthority, '3pj.cx.accounts.syncprovider')

# for intent in adapterRoot.iter('sync-adapter'):
# 	intent.set(contentAuthority,packageName + '.cx.accounts.syncprovider')

adapterTree.write(sync_adapter, 'UTF-8')
