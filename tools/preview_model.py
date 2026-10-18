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
subprocess.run([sys.executable, str(root/"tools/model_coupe_trimesh.py")], check=True)

scene = trimesh.load(model, force="scene")
fig = plt.figure(figsize=(12, 7))
ax = fig.add_subplot(111, projection="3d", computed_zorder=False)
ax.set_title("Ayo Race • obrót: lewy przycisk myszy • zoom: kółko myszy")

# Render contiguous triangles, not every Nth triangle.
# The old preview selected isolated triangles from the body surface, which
# produced the red dotted/striped "exploded mesh" seen in screenshots.
# Display axes: horizontal X (width), horizontal Y (length), vertical Z (height).
for geom in scene.geometry.values():
    if not hasattr(geom, "faces") or not len(geom.faces):
        continue
    all_triangles = geom.vertices[geom.faces]
    polygons = all_triangles[:, :, [0, 2, 1]]
    rgba = getattr(geom.visual, "vertex_colors", None)
    color = (np.asarray(rgba[0,:3])/255 if rgba is not None and len(rgba)
             else [0.72,0.72,0.73])
    ax.add_collection3d(Poly3DCollection(
        polygons, facecolors=color, edgecolors="none",
        linewidths=0, alpha=1.0, zsort="average"))

ax.set_xlim(-1.35,1.35)
ax.set_ylim(-1.95,1.95)
ax.set_zlim(0,1.35)
ax.set_box_aspect([2.7,3.9,1.4])
ax.view_init(elev=23, azim=-58)
ax.set_xlabel("X (szerokość)")
ax.set_ylabel("Y (długość)")
ax.set_zlabel("Z (wysokość)")
plt.tight_layout()
plt.show()
