#!/usr/bin/env python3
"""Minimal geometry smoke checks for the offline Ayo Race GLB model."""
from pathlib import Path
import subprocess
import sys
import trimesh

root=Path(__file__).resolve().parents[1]
subprocess.run([sys.executable,str(root/"tools/model_coupe_trimesh.py")],check=True)
path=root/"assets/models/ayo_race_concept.glb"
scene=trimesh.load(path,force="scene")
assert path.stat().st_size>1000
names=list(scene.geometry)
assert any("arched side panels" in n for n in names),names
assert sum("tire" in n for n in names)==4,names
assert sum("alloy rim" in n for n in names)==4,names
body=next(g for n,g in scene.geometry.items() if "arched side panels" in n)
assert len(body.faces)>1000
assert body.bounds[0,0]<-.8 and body.bounds[1,0]>.8
for n,g in scene.geometry.items():
    assert g.is_empty is False,n
print("OK: GLB exports, body + 4 tires + 4 rim meshes and geometry bounds")
