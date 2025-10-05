import xml.etree.ElementTree as ET

# Input and output file paths
input_xml = './quran-uthmani.xml'
output_txt = './metadata.txt'

tree = ET.parse(input_xml)
root = tree.getroot()

with open(output_txt, 'w', encoding='utf-8') as f:
    for surah in root.findall('sura'):
        surah_index = surah.get('index')
        surah_name = surah.get('name')
        # Check bismillah on first child aya
        first_aya = surah.find('aya')
        has_bismillah = '0'
        if first_aya is not None:
            bismillah_attr = first_aya.get('bismillah')
            if bismillah_attr is not None and bismillah_attr.strip():
                has_bismillah = '1'
        f.write(f'{surah_index}|{has_bismillah}\n')
print(f'Metadata written to {output_txt}')
