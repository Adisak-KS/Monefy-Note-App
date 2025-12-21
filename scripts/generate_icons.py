"""
Generate app icons and splash images from SVG
Uses svglib (pure Python, no system dependencies)
"""
import os
import sys

try:
    from svglib.svglib import svg2rlg
    from reportlab.graphics import renderPM
    from PIL import Image
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Run: pip install svglib reportlab pillow")
    sys.exit(1)

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
ASSETS_DIR = os.path.join(PROJECT_DIR, "assets", "images")
SVG_PATH = os.path.join(ASSETS_DIR, "app_icon.svg")

def svg_to_png(svg_path: str, output_path: str, width: int, height: int):
    """Convert SVG to PNG at specified size"""
    # Load SVG
    drawing = svg2rlg(svg_path)
    if drawing is None:
        raise ValueError(f"Could not load SVG: {svg_path}")

    # Calculate scale
    scale_x = width / drawing.width
    scale_y = height / drawing.height
    scale = min(scale_x, scale_y)

    drawing.width = width
    drawing.height = height
    drawing.scale(scale, scale)

    # Render to PNG
    renderPM.drawToFile(drawing, output_path, fmt="PNG")
    print(f"Created: {output_path} ({width}x{height})")

def create_foreground_icon(svg_path: str, output_path: str, size: int = 1024):
    """Create foreground icon with padding for Android adaptive icons"""
    # Load SVG
    drawing = svg2rlg(svg_path)
    if drawing is None:
        raise ValueError(f"Could not load SVG: {svg_path}")

    # First render at full size
    temp_path = output_path + ".temp.png"
    scale = size / max(drawing.width, drawing.height)
    drawing.width = size
    drawing.height = size
    drawing.scale(scale, scale)
    renderPM.drawToFile(drawing, temp_path, fmt="PNG")

    # Open with PIL and add padding
    img = Image.open(temp_path)
    img = img.convert("RGBA")

    # Create new image with padding (for adaptive icon safe zone)
    padded_size = size
    new_img = Image.new("RGBA", (padded_size, padded_size), (0, 0, 0, 0))

    # Resize original to fit with padding
    icon_size = int(size * 0.6)  # 60% of total size for safe zone
    img_resized = img.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

    # Center it
    offset = (padded_size - icon_size) // 2
    new_img.paste(img_resized, (offset, offset))

    new_img.save(output_path, "PNG")

    # Clean up temp file
    os.remove(temp_path)
    print(f"Created: {output_path} ({padded_size}x{padded_size}) with padding")

def main():
    print("=" * 50)
    print("Generating App Icons and Splash Images")
    print("=" * 50)

    # Check SVG exists
    if not os.path.exists(SVG_PATH):
        print(f"Error: SVG not found at {SVG_PATH}")
        sys.exit(1)

    print(f"\nSource: {SVG_PATH}")
    print(f"Output: {ASSETS_DIR}\n")

    # Ensure output directory exists
    os.makedirs(ASSETS_DIR, exist_ok=True)

    # Generate icons
    try:
        # 1. App icon (1024x1024)
        svg_to_png(
            SVG_PATH,
            os.path.join(ASSETS_DIR, "app_icon.png"),
            1024, 1024
        )

        # 2. Foreground icon for adaptive icons (1024x1024 with padding)
        create_foreground_icon(
            SVG_PATH,
            os.path.join(ASSETS_DIR, "app_icon_foreground.png"),
            1024
        )

        # 3. Splash icon (512x512)
        svg_to_png(
            SVG_PATH,
            os.path.join(ASSETS_DIR, "splash_icon.png"),
            512, 512
        )

        print("\n" + "=" * 50)
        print("All icons generated successfully!")
        print("=" * 50)
        print("\nNext steps:")
        print("1. Run: dart run flutter_native_splash:create")
        print("2. Run: dart run flutter_launcher_icons")

    except Exception as e:
        print(f"\nError generating icons: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
