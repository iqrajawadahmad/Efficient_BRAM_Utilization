from PIL import Image
import numpy as np

# Load and force resize to 512x512
img = Image.open("input512.png").convert("L").resize((512, 512))

# Convert to numpy array
pixels = np.array(img.getdata(), dtype=np.uint8)

# Confirm size
print("Image size:", img.size)
print("Total pixels:", len(pixels))

# Write to .mem file
with open("image_data.mem", "w") as f:
    for p in pixels:
        f.write(f"{p:02x}\n")

print("✅ Done. Written:", len(pixels), "lines to image_data.mem")
