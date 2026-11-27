import random
import sys
import zipfile

random.seed(7)
destino = sys.argv[1]

frases_base = [
    "A manhã estava clara e o vento passava devagar pelo quintal.",
    "Ninguém em casa parecia ter pressa naquele dia.",
    "O almoço demorou mais do que de costume.",
    "Cerca de dez pessoas esperavam na porta da igreja.",
    "Havia uma cerca baixa entre as duas casas, coberta de flores.",
    "Então o relógio da sala bateu as horas e todos se calaram.",
    "A rua de Matacavalos ficava em silêncio depois das nove.",
    "Eu me lembro bem do cheiro do café naquela cozinha.",
]
eventos = {
    "Capitu": [
        "Encontrei Capitu no quintal, desenhando no muro com um prego.",
        "A conversa com Capitu durou até o fim da tarde.",
        "Foi Capitu quem teve a ideia de escrever a carta.",
    ],
    "José Dias": [
        "José Dias apareceu na sala com o ar solene de sempre.",
        "Ninguém contrariava José Dias quando ele falava de política.",
    ],
    "Escobar": [
        "No seminário conheci Escobar, um rapaz educado e atento.",
        "A visita de Escobar trouxe notícias da cidade.",
    ],
}

capitulos = []
for n in range(1, 31):
    paragrafos = []
    for _ in range(14):
        frases = random.sample(frases_base, 4)
        if n <= 12 and random.random() < 0.5:
            frases.insert(random.randint(0, 4), random.choice(eventos["Capitu"]))
        if n in (2, 3, 4, 10, 11, 25):
            frases.insert(random.randint(0, 4), random.choice(eventos["José Dias"]))
        if n in (8, 9, 28):
            frases.insert(random.randint(0, 4), random.choice(eventos["Escobar"]))
        paragrafos.append("<p>" + " ".join(frases) + "</p>")
    corpo = f'<h2>Capítulo {n}</h2>\n' + "\n".join(paragrafos)
    capitulos.append(corpo)

def xhtml(titulo, corpo):
    return f"""<?xml version="1.0" encoding="utf-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" lang="pt-BR"><head><title>{titulo}</title></head><body>
{corpo}
</body></html>"""

with zipfile.ZipFile(destino, "w") as z:
    z.writestr(zipfile.ZipInfo("mimetype"), "application/epub+zip", compress_type=zipfile.ZIP_STORED)
    z.writestr("META-INF/container.xml", """<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>""")
    itens, espinha, pontos = [], [], []
    for i, corpo in enumerate(capitulos, 1):
        nome = f"cap{i:02d}.xhtml"
        z.writestr("OEBPS/" + nome, xhtml(f"Capítulo {i}", corpo))
        itens.append(f'<item id="c{i}" href="{nome}" media-type="application/xhtml+xml"/>')
        espinha.append(f'<itemref idref="c{i}"/>')
        pontos.append(f'<navPoint id="n{i}" playOrder="{i}"><navLabel><text>Capítulo {i}</text></navLabel><content src="{nome}"/></navPoint>')
    z.writestr("OEBPS/toc.ncx", f"""<?xml version="1.0" encoding="utf-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1"><head><meta name="dtb:uid" content="fuxico-teste"/></head>
<docTitle><text>Livro de teste do Fuxico</text></docTitle><navMap>{''.join(pontos)}</navMap></ncx>""")
    z.writestr("OEBPS/content.opf", f"""<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="uid">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>Livro de teste do Fuxico</dc:title><dc:language>pt-BR</dc:language><dc:identifier id="uid">fuxico-teste</dc:identifier><dc:creator>Fuxico</dc:creator></metadata>
<manifest><item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>{''.join(itens)}</manifest>
<spine toc="ncx">{''.join(espinha)}</spine></package>""")
print("ok", destino)
