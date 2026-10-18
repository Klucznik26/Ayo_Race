# Ayo Race

An experimental miniature 3D racer for Linux (KDE Plasma and Sayari).

**Demo 0.1**: a black oval track with white racing lines and a red 3D sports car that drives itself continuously.

The executable is written **entirely in NASM x86-64**. It calls system libraries SDL2, OpenGL and GLU through their C ABI. This is a working graphics prototype, not yet the final high-detail art style.

## Fedora dependencies

```bash
sudo dnf install nasm gcc SDL2-devel mesa-libGL-devel mesa-libGLU-devel
```

## Build and run

```bash
bash build.sh
./ayo-race
```

Run as a normal desktop application in KDE Plasma or inside Sayari (provided Sayari's Wayland/XWayland/SDL window hosting is working).

**ESC** closes the window. The car is automatic and the track repeats indefinitely.

## Technical choices

- NASM x86-64, System V AMD64 ABI
- SDL2 desktop/window/input, OpenGL 2.1-compatible fixed pipeline, GLU
- Procedural oval track and procedural 3D car (no external assets)
- CPU computes the path and heading in assembly, GPU renders geometry
- Next: polished car mesh, shadows, better lighting, material shaders, smooth camera

The project does not use any original Micro Machines or Hot Wheels assets.

## Separate 3D model workflow (no Blender needed)

The offline model generator lives in `tools/model_coupe_trimesh.py`.
It makes a **new experimental GLB/OBJ model** using explicit wheel-arch contours.
This model is **not yet loaded by the NASM game**: the game still renders its
older generated mesh; the external model is a separate model-development branch
of work.

On Fedora:

```bash
cd "/home/marek/AYO Projekty/Ayo_Race"
python3 -m venv .venv
source .venv/bin/activate
pip install numpy trimesh matplotlib
python3 tools/test_model.py
python3 tools/preview_model.py
```

Drag with the mouse to rotate the model; scroll to zoom. The preview does not
require Blender. Files are created under `assets/models/` (GLB and OBJ).
When the shape is satisfactory, we will import this mesh into the game's ASM
renderer instead of using the old `tools/generate_car.py` body generator.
