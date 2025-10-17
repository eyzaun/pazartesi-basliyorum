from __future__ import annotations

import struct
import zlib
from pathlib import Path


def _chunk(tag: bytes, data: bytes) -> bytes:
    length = struct.pack("!I", len(data))
    crc = struct.pack("!I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    return length + tag + data + crc


def generate_icon(path: Path, size: int, color: tuple[int, int, int, int]) -> None:
    width = height = size
    r, g, b, a = color
    row = bytes([r, g, b, a]) * width
    raw = b"".join(b"\x00" + row for _ in range(height))

    ihdr = struct.pack("!IIBBBBB", width, height, 8, 6, 0, 0, 0)
    compressed = zlib.compress(raw, level=9)

    png_bytes = (
        b"\x89PNG\r\n\x1a\n"
        + _chunk(b"IHDR", ihdr)
        + _chunk(b"IDAT", compressed)
        + _chunk(b"IEND", b"")
    )

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png_bytes)


def main() -> None:
    base = Path("web/icons")
    base.mkdir(parents=True, exist_ok=True)

    color = (108, 99, 255, 255)
    for size in (192, 512):
        generate_icon(base / f"Icon-{size}.png", size, color)
        generate_icon(base / f"Icon-maskable-{size}.png", size, color)


if __name__ == "__main__":
    main()
