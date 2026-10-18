#!/usr/bin/env python3
"""Model viewer without Blender: mouse drag rotates, scroll zooms.
Run: python3 tools/preview_model.py
"""
from pathlib import Path
import subprocess
import sys
import numpy as np
import trimesh
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

root = Path(__file__).resolve().parents[1]
model = root / "assets/models/ayo_race_concept.glb"
if not model.exists():
    subprocess.run([sys.executable, str(root/"tools/model_coupe_trimesh.py")], check=True)

scene = trimesh.load(model, force="scene")
fig = plt.figure(figsize=(12, 7))
ax = fig.add_subplot(111, projection="3d", computed_zorder=False)
ax.set_title("Ayo Race • obrót: lewy przycisk myszy • zoom: kółko myszy")

# Viewport quality is intentionally limited to keep mouse rotation responsive.
for geom in scene.geometry.values():
    if not hasattr(geom, "faces") or not len(geom.faces):
        continue
    idx = np.arange(0,len(geom.faces),max(1,len(geom.faces)//950))
    polygons = geom.vertices[geom.faces[idx]]
    rgba = getattr(geom.visual, "vertex_colors", None)
    color = (np.asarray(rgba[0,:3])/255 if rgba is not None and len(rgba)
             else [0.72,0.72,0.73])
    c = Poly3DCollection(polygons, facecolors=color, edgecolors="none")
    ax.add_collection3d(c)

ax.set_xlim(-2,2)
ax.set_ylim(-.2,1.8)
ax.set_zlim(-2,2)
ax.set_box_aspect([4,2,4])
ax.view_init(elev=27, azim=-68)
ax.set_xlabel("X"); ax.set_ylabel("Y"); ax.set_zlabel("Z")
plt.tight_layout()
plt.show()
