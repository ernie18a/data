"""抽樣（分類體系歸納用）與依檔案大小平衡分批（逐份歸類用）。"""
import glob, os, random
ROOT = os.path.dirname(os.path.abspath(__file__)); SRC = os.path.dirname(ROOT); W = os.path.join(ROOT, 'work')
files = sorted(os.path.basename(f) for f in glob.glob(os.path.join(SRC, '*.md')))
random.seed(1)
samp = random.sample(files, 45)
for i in range(3):
    open(os.path.join(W, f'sample_{i}.txt'), 'w').write('\n'.join(os.path.join(SRC, f) for f in samp[i*15:(i+1)*15]) + '\n')
NB = 20
size = {f: os.path.getsize(os.path.join(SRC, f)) for f in files}
bins = [[0, []] for _ in range(NB)]
for f in sorted(files, key=lambda f: -size[f]):
    b = min(bins, key=lambda x: x[0]); b[0] += size[f]; b[1].append(f)
for i, (s, fs) in enumerate(bins):
    open(os.path.join(W, f'batch_{i:02d}.txt'), 'w').write('\n'.join(os.path.join(SRC, f) for f in sorted(fs)) + '\n')
    print(i, len(fs), s)
