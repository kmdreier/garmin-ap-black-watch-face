"""Generate the date-wheel images and an illustrative preview of the watch renderer.

Run with Python 3 and Pillow. The clean generated AP dial is displayed with live hands and date drawn over it.
The preview uses the same geometry and resources as the Monkey C face.
"""
from pathlib import Path
from math import sin, cos, pi, atan2, hypot
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "resources" / "drawables"
S = 3
FONT_ROOT = Path("/System/Library/Fonts/Supplemental")
ARIAL = FONT_ROOT / "Arial.ttf"
BOLD = FONT_ROOT / "Arial Bold.ttf"
SERIF = FONT_ROOT / "Times New Roman.ttf"


def pt(angle, radius, center=(180, 180)):
    return (center[0] + sin(angle) * radius, center[1] - cos(angle) * radius)


def draw_dial():
    return Image.open(OUT / "ap-black-v2.png").convert("RGB").resize((360,360),Image.Resampling.LANCZOS)


def date_wheels():
    font=ImageFont.truetype(str(ARIAL),23*S)
    xml=['<resources>']
    aod_font=ImageFont.truetype(str(BOLD),16*S)
    for day in range(1,32):
        for mode,fill,ink,f in [('date','#f5f5f1','#121415',font),
                               ('dim','#000000','#858c90',aod_font)]:
            im=Image.new('RGB',(32*S,22*S),fill)
            d=ImageDraw.Draw(im)
            bounds=d.textbbox((0,0),str(day),font=f,anchor='lt')
            w,h=bounds[2]-bounds[0],bounds[3]-bounds[1]
            d.text(((32*S-w)/2,(22*S-h)/2),str(day),font=f,fill=ink,anchor='lt')
            im.resize((32,22),Image.Resampling.LANCZOS).save(OUT/f'{mode}{day:02}.png')
            xml.append(f'    <bitmap id="{mode.title()}{day:02}" filename="{mode}{day:02}.png" dithering="none" compress="true" automaticPalette="true"/>')
    xml.append('</resources>')
    (OUT/'dates.xml').write_text('\n'.join(xml)+'\n')


def render_preview(dial):
    im=dial.resize((720,720),Image.Resampling.NEAREST)
    d=ImageDraw.Draw(im)
    # Use the same date-wheel image the watch draws.
    wheel=Image.open(OUT/'date27.png').resize((64,44),Image.Resampling.NEAREST)
    im.paste(wheel,(295*2,171*2))

    def line(points,color,width=1):
        d.line([(round(x*2),round(y*2)) for x,y in points],fill=color,width=width*2)
    def circle(center,r,color):
        x,y=center
        d.ellipse((round((x-r)*2),round((y-r)*2),round((x+r)*2),round((y+r)*2)),fill=color)
    def polygon(points,color):
        d.polygon([(round(x*2),round(y*2)) for x,y in points],fill=color)
    def hand(angle,length,width,color):
        tip=pt(angle,length); neck=pt(angle,length-3); base=pt(angle,-15)
        dx,dy=cos(angle)*width,sin(angle)*width
        polygon([(tip[0]-dx*.65,tip[1]-dy*.65),(tip[0]+dx*.65,tip[1]+dy*.65),(neck[0]+dx,neck[1]+dy),(base[0]+dx*.55,base[1]+dy*.55),(base[0]-dx*.55,base[1]-dy*.55),(neck[0]-dx,neck[1]-dy)],color)

    hour=(10+10/60)*pi/6
    minute=10*pi/30
    hand(hour,87,5,'#747f82');hand(hour,85,3,'#f4f7f5')
    hand(minute,124,4,'#747f82');hand(minute,122,2,'#f4f7f5')
    second=37*pi/30
    line([pt(second,-25),pt(second,131)],'#eaf2ef')
    circle((180,180),5,'#eaf2ef');circle((180,180),3,'#eaf2ef')
    im.resize((360,360),Image.Resampling.LANCZOS).save(ROOT/'preview.png')


if __name__ == '__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    date_wheels()
    render_preview(draw_dial())
    print('Created AP date wheels and preview.png')
