"""Rebuild the six original geometric Game Center badges in Sloglide's palette."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "metadata/game_center"
BG, INK, ACCENT, MUTED = "#1E151C", "#F2EDF1", "#D666C4", "#A993A5"


def draw_badges():
    DEST.mkdir(parents=True, exist_ok=True)
    scale = 3
    font_path = "/System/Library/Fonts/Avenir Next.ttc"
    for slug, number, kind in [
        ("first_film", "1", "film"), ("ten_films", "10", "film"),
        ("fifty_films", "50", "film"), ("hundred_films", "100", "film"),
        ("first_series", "1", "series"), ("ten_grades", "10", "grades"),
    ]:
        image = Image.new("RGB", (512 * scale, 512 * scale), BG)
        draw = ImageDraw.Draw(image)
        def box(values):
            return tuple(v * scale for v in values)
        draw.ellipse(box((34, 34, 478, 478)), outline=MUTED, width=2 * scale)
        draw.arc(box((48, 48, 464, 464)), 205, 330, fill=ACCENT, width=8 * scale)
        if kind == "film":
            draw.rounded_rectangle(box((112, 130, 400, 370)), radius=12 * scale, outline=INK, width=5 * scale)
            for x in (124, 370):
                for y in range(148, 350, 40):
                    draw.rectangle(box((x, y, x + 18, y + 22)), fill=ACCENT)
        elif kind == "series":
            for offset in (24, 12, 0):
                draw.rounded_rectangle(box((126 - offset, 154 - offset, 386 - offset, 350 - offset)),
                                       radius=12 * scale, fill=BG, outline=INK if offset == 0 else MUTED, width=4 * scale)
            draw.line(box((210, 378, 302, 378)), fill=ACCENT, width=6 * scale)
        else:
            draw.rounded_rectangle(box((132, 124, 380, 380)), radius=14 * scale, outline=INK, width=5 * scale)
            for index in range(5):
                draw.ellipse(box((172 + index * 36, 330, 186 + index * 36, 344)), fill=ACCENT)
        font = ImageFont.truetype(font_path, (86 if len(number) < 3 else 70) * scale)
        draw.text((256 * scale, 244 * scale), number, font=font, fill=INK, anchor="mm", stroke_width=scale)
        image.resize((512, 512), Image.Resampling.LANCZOS).save(DEST / (slug + ".png"))


if __name__ == "__main__":
    draw_badges()
