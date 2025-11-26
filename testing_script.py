import numpy as np

IMAGE_SIZE = 512
KERNEL_SIZE = 5

# --------------------------
# LOAD image.mem (clean lines)
# --------------------------
with open("image.mem", "r") as f:
    hex_values = []
    for line in f:
        # Remove comments starting with //
        line = line.split("//")[0].strip()
        if line:  # skip empty lines
            hex_values.append(line)

image = np.array([int(x, 16) for x in hex_values], dtype=np.uint8)
image = image.reshape((IMAGE_SIZE, IMAGE_SIZE))  # row-major


# --------------------------
# LOAD NIP output
# --------------------------
with open("pixel_outputs.txt", "r") as f:
    nip_pixels = [line.strip() for line in f.readlines()]

# convert hex strings or decimal to int
nip_pixels = [
    int(v, 16) if all(c in "0123456789abcdefABCDEF" for c in v) else int(v)
    for v in nip_pixels
]


# --------------------------
# VERIFY STREAMING
# --------------------------
errors = 0
index = 0  # pointer in nip_pixels

for row in range(0, IMAGE_SIZE - (KERNEL_SIZE - 1)):  # 0 → 508
    for col in range(0, IMAGE_SIZE):  # 0 → 511

        # expected 5 pixels (column-wise slice)
        expected = [
            image[row + k][col] for k in range(KERNEL_SIZE)
        ]

        # actual from file
        actual = nip_pixels[index : index + KERNEL_SIZE]

        if expected != actual:
            print(f"Mismatch at row={row}, col={col}")
            print(f"Expected: {expected}")
            print(f"Got     : {actual}")
            errors += 1
            # You may break here if you don't want full scan
            # break

        index += KERNEL_SIZE


print("\n---------------")
print("Verification DONE")
print(f"Total errors found: {errors}")
print("---------------")
