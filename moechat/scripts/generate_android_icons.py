#!/usr/bin/env python3
"""Generate Android app icons from source image."""

from PIL import Image
import os

# Android icon sizes
SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# Source image
SOURCE = 'assets/logo1.png'
OUTPUT_DIR = 'android/app/src/main/res'

def generate_icons():
    # Open source image
    img = Image.open(SOURCE)
    
    # Convert to RGBA if needed
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Generate icons for each density
    for folder, size in SIZES.items():
        output_path = os.path.join(OUTPUT_DIR, folder, 'ic_launcher.png')
        
        # Resize with high quality
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save
        resized.save(output_path, 'PNG')
        print(f'Generated: {output_path} ({size}x{size})')
    
    print('\nAndroid icons generated successfully!')

if __name__ == '__main__':
    generate_icons()
