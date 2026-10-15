"""Fetch the exact upstream base weights; never trains or merges adapters."""
import hashlib
from pathlib import Path
from huggingface_hub import hf_hub_download

ROOT=Path(__file__).resolve().parent
REVISION='c810673187f190e6e6dfd989806541507468f234'
EXPECTED='c64903bc27bbe8b8a9ebb9086909a524b182baf93a245ca90dcb57e9abfb39e4'
def digest(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(8*1024*1024),b''):
            h.update(block)
    return h.hexdigest()

if __name__=='__main__':
    target=ROOT/'model'/'model.safetensors'
    if target.exists() and digest(target)==EXPECTED:
        print('Base model already present; SHA256 verified.')
    else:
        print('Downloading cturan/Lamba-750M base weights (about 1.5 GB)...')
        path=Path(hf_hub_download(repo_id='cturan/Lamba-750M',filename='model.safetensors',revision=REVISION,local_dir=ROOT/'model'))
        if digest(path)!=EXPECTED:
            raise RuntimeError('Base weights SHA256 mismatch. Refusing to use them.')
        print('Base weights downloaded; SHA256 verified.')
