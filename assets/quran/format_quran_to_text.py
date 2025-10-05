import xml.etree.ElementTree as ET

# Input and output file paths
input_xml = './quran-uthmani.xml'
output_txt = './quran-uthmani.txt'
copyright = """

# PLEASE DO NOT REMOVE OR CHANGE THIS COPYRIGHT BLOCK
#====================================================================
#
#  Tanzil Quran Text (Uthmani, Version 1.1)
#  Copyright (C) 2007-2025 Tanzil Project
#  License: Creative Commons Attribution 3.0
#
#  This copy of the Quran text is carefully produced, highly 
#  verified and continuously monitored by a group of specialists 
#  at Tanzil Project.
#
#  TERMS OF USE:
#
#  - Permission is granted to copy and distribute verbatim copies 
#    of this text, but CHANGING IT IS NOT ALLOWED.
#
#  - This Quran text can be used in any website or application, 
#    provided that its source (Tanzil Project) is clearly indicated, 
#    and a link is made to tanzil.net to enable users to keep
#    track of changes.
#
#  - This copyright notice shall be included in all verbatim copies 
#    of the text, and shall be reproduced appropriately in all files 
#    derived from or containing substantial portion of this text.
#
#  Please check updates at: http://tanzil.net/updates/
#
#====================================================================
"""

tree = ET.parse(input_xml)
root = tree.getroot()

with open(output_txt, 'w', encoding='utf-8') as f:
    for surah in root.findall('sura'):
        surah_index = surah.get('index')
        surah_name = surah.get('name')
        # Check bismillah on first child aya
        for aya in surah.findall('aya'):
            aya_index = aya.get('index')
            aya_text = aya.get('text')
            f.write(f'{surah_index}|{aya_index}|{aya_text}\n')
    
    f.write(copyright)

print(f'formatted quran written to {output_txt}')
