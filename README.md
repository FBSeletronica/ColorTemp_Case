# ColorTemp Case

3D-printed case for the [ColorTemp](https://github.com/MechatronixLab/ColorTemp/tree/master) project — a color-coded thermometer by Mechatronix Lab.

Modeled in OpenSCAD from the board's measurements (STEP), with a translucent lid that acts as a diffuser for the LED.

## Files

| File | Description |
|---|---|
| [ColorTemp_Case.scad](ColorTemp_Case.scad) | Parametric source (OpenSCAD) |
| [ColorTemp_Case_base.stl](ColorTemp_Case_base.stl) | Base, ready to slice |
| [ColorTemp_Case_lid.stl](ColorTemp_Case_lid.stl) | Lid/diffuser, ready to slice |

## Board fit

Base measurements (taken from the STEP file): 27.5 x 27.5 mm board, 1.6 mm thick.

- **USB-C** on the Y+ edge (connector rises 3.85 mm above the board)
- **Buttons** (SW1/SW2) on the X+ edge, with the actuator almost touching the wall
- The board snaps onto 4 locating pins and rests on standoffs
- A center hole in the bottom of the base allows for ventilation and lets you push the board out when disassembling

## Assembly

1. Snap the board onto the base's 4 locating pins.
2. Close the case by pressing the lid down until it locks onto the 4 snap blocks (1 per side) — no glue or screws needed.
3. To disassemble, push the board out from underneath through the base's center hole.

If the lid fit is too tight or too loose for your printer, adjust `snap_protrude`, `snap_depth`, or `fit_gap` near the top of the `.scad` file.

## Printing recommendations

- **0% infill** on both parts — with walls this thin, any infill would kill the lid's light diffusion and might even prevent it from closing properly.
- **Lid:** force **1 single perimeter/wall-loop** in your slicer (the default is usually 2+) to get a wall thin enough (~0.45–0.5 mm) to diffuse the LED's light. Tested with a 0.4 mm nozzle.
- **Neither part needs supports** — the lid's internal snap ramp is designed at ~45° and the snap blocks are just reliefs on a vertical wall.

## Generating the parts

At the end of `ColorTemp_Case.scad`, change the `part` variable to choose what to preview/export:

```scad
part = "base";        // base only
part = "lid";         // lid only
part = "both_apart";  // both parts side by side, already in the correct print orientation — use this to export/slice
part = "assembled";   // both parts stacked, just to VISUALLY CHECK the fit — not meant for printing
```

## Credits

- Electronics project: [ColorTemp — Mechatronix Lab](https://github.com/MechatronixLab/ColorTemp/tree/master)
- Case: Fabio / Embarcados
