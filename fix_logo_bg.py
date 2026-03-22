from PIL import Image
import numpy as np

path = r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\assets\images\splash\splash_logo_mark.png'

img = Image.open(path).convert("RGBA")
data = np.array(img)

# Make near-black pixels transparent (background removal)
r, g, b, a = data[:,:,0], data[:,:,1], data[:,:,2], data[:,:,3]
mask = (r < 30) & (g < 30) & (b < 30)
data[mask, 3] = 0

result = Image.fromarray(data)
result.save(path, 'PNG')
print('Logo background made transparent.')
