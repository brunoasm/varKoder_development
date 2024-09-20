from idelucs.utils import cgrFasta
from PIL import Image
import numpy as np
from math import sqrt
import sys
import os

# Load the array from the cgrFasta function
arr = cgrFasta(sys.argv[1], k=7)[1][0]
side_len = int(sqrt(len(arr)))

arr = arr.reshape([side_len, side_len])

# Scale the array for image use (0-255 grayscale)
arr_scaled = (255 * (arr - arr.min()) / (arr.max() - arr.min())).astype(np.uint8)

# Create the image
img = Image.fromarray(arr_scaled, 'L')

# Prepare the output directory and file path
output_dir = "cgr_imgs/"
os.makedirs(output_dir, exist_ok=True)
base_name = os.path.basename(sys.argv[1])
output_file = os.path.join(output_dir, base_name.replace('.fasta', '+k7.png'))

# Save the image with maximum compression
img.save(output_file, "PNG", optimize=True, compression="9")

print(f"Image saved to {output_file}")

