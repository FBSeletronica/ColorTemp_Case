$fn = 72;

// ---------- PLACA (medido no STEP) ----------
board_size = 27.5;
board_t    = 1.6;

usbc_x_span   = [-4.62, 4.62];
usbc_h_above  = 3.85;
usbc_h_below  = 0.4;

btn_y        = [3.25, -3.25];   // SW1, SW2
btn_hole_h   = 2.6;
btn_z_bottom = -0.3;

// ---------- FOLGAS E FIXAÇÃO DA PLACA ----------
board_clear = 0.4;
floor_t     = 2.0;
standoff_h  = 2.5;
pin_d       = 3.2;
pin_h       = 1.7;
standoff_d  = 6.0;

// margem solida acima do recorte mais alto — dentro dela a tampa
// desliza livre ate um RESSALTO interno (ver lid()) que trava a
// profundidade, sempre no mesmo lugar
rim_margin = 2.3;   // minimo seguro: overlap_h (2.0) + 0.3mm de folga
overlap_h  = 2.0;      // profundidade de encaixe ate travar no ressalto
shoulder_w = 1.5;      // quanto o anel estreita acima do encaixe —
                        // e' nisso que a borda da base bate

// ---------- PEGADA / PROPORÇÃO DO CUBO ----------
// (case_r e' derivado mais abaixo, de pocket_r + wall_t_base, pra
// garantir que a tampa e a base tenham o MESMO raio de canto)

top_round_h = 5.0;
top_round_shrink = 4.0;
total_h     = 34.0;

// ---------- PAREDES (mais finas que a v4) ----------
wall_t_lid  = 0.5;    // parede da tampa (difusor) — alvo: 1 SO
                        // perimetro/wall-loop no fatiador (nao 2!),
                        // ~0.45-0.5mm com bico 0.4mm. 0% infill.
                        // Esse e' praticamente o minimo confiavel —
                        // abaixo disso a extrusora comeca a falhar
                        // linha (buracos, fios soltos).
wall_t_base = 1.0;    // parede da base — tambem mais fina, ainda
                        // deixa vazar um pouco de luz, aproximando o
                        // brilho do LED (que fica escondido aqui embaixo)
fit_gap     = 0.15;   // folga do encaixe (livre ate travar no ressalto)

case_w = board_size + 2*(board_clear + wall_t_base);  // ~30.3mm

// ============================================================
// GEOMETRIA AUXILIAR
// ============================================================
module rrect(w, r) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r), sy*(w/2 - r)])
                circle(r = r);
    }
}

pocket_r = 3.75 + board_clear;
pocket_w = board_size + 2*board_clear;
boss_xy  = [ [10, 10], [-10, 10], [10, -10], [-10, -10] ];

// raio de canto EXTERNO, usado tanto pela base quanto pela tampa —
// derivado do raio real do bolso (que segue o formato da placa),
// nao mais um numero solto. Garante que base e tampa tenham o
// MESMO raio de canto, entao a folga (fit_gap) fica uniforme em
// toda a volta, inclusive nos 4 cantos — nao so nas faces retas.
case_r = pocket_r + wall_t_base;   // ~5.15mm

module pocket_cut(h, preserve_h) {
    difference() {
        linear_extrude(height = h)
            rrect(pocket_w, pocket_r);
        for (p = boss_xy)
            translate([p[0], p[1], -1])
                cylinder(h = preserve_h + 1, d = standoff_d);
    }
}

board_bottom = floor_t + standoff_h;
board_top    = board_bottom + board_t;
usbc_top_abs = board_top + usbc_h_above;
btn_top_abs  = board_top + (btn_z_bottom + btn_hole_h);
func_h       = max(usbc_top_abs, btn_top_abs) + rim_margin;

// ============================================================
// BOTÃO "PORTINHOLA" — corte em U (3 lados) ao redor de uma aba
// retangular da propria parede, deixando o 4o lado (topo) preso
// como dobradica. A aba fica na espessura NORMAL da parede (nao
// precisa afinar) — quem da a flexibilidade e' o corte em volta,
// nao o material fino. Fisicamente e' bem mais facil de flexionar
// que uma membrana presa nos 4 lados.
// ============================================================
flap_w    = 3.8;   // largura da aba (limitado: 2 botoes a 6.5mm um
                     // do outro; com door_slot=0.5 da folga real de
                     // ~1.7mm entre as duas portinholas — aumentada
                     // de 4.6mm porque a 0.9mm original elas
                     // grudaram na impressao mesmo com suporte)
flap_h    = 4.5;    // altura da aba
door_slot = 0.5;    // largura do corte em U

module btn_cutout(y_center) {
    z_center = board_top + btn_z_bottom + btn_hole_h/2;
    y0 = y_center - flap_w/2;
    y1 = y_center + flap_w/2;
    z0 = z_center - flap_h/2;   // borda de baixo (cortada)
    z1 = z_center + flap_h/2;   // borda de cima (dobradica, NAO corta)

    x_start = pocket_w/2 - 1;             // comeca de dentro do bolso
    x_len   = case_w/2 + 2 - x_start;      // vai bem alem da face externa

    union() {
        // fenda esquerda
        translate([x_start, y0 - door_slot, z0])
            cube([x_len, door_slot, flap_h]);
        // fenda direita
        translate([x_start, y1, z0])
            cube([x_len, door_slot, flap_h]);
        // fenda de baixo
        translate([x_start, y0 - door_slot, z0 - door_slot])
            cube([x_len, flap_w + 2*door_slot, door_slot]);
    }
}

// ============================================================
// BASE
// ============================================================
module base() {
    difference() {
        union() {
            difference() {
                linear_extrude(height = func_h)
                    rrect(case_w, case_r);
                translate([0, 0, floor_t])
                    pocket_cut(func_h, board_bottom - floor_t);
            }
            for (p = boss_xy)
                translate([p[0], p[1], 0])
                    cylinder(h = board_bottom, d = standoff_d);
            for (p = boss_xy)
                translate([p[0], p[1], board_bottom - 0.2])
                    cylinder(h = pin_h + 0.2, d = pin_d);
        }

        // ---- USB-C (parede da borda Y+) ----
        translate([usbc_x_span[0], pocket_w/2 - 1, board_top - usbc_h_below])
            cube([usbc_x_span[1]-usbc_x_span[0], wall_t_base + 2, usbc_h_above + usbc_h_below]);

        // ---- botoes com portinhola (parede da borda X+) ----
        for (y = btn_y)
            btn_cutout(y);
    }
}

// ============================================================
// TAMPA — capa difusora lisa, com anel interno continuo que trava
// contra a borda de cima da base (batente mecanico, veda 360°).
// ============================================================
module lid() {
    flat_h   = total_h - func_h - top_round_h;
    ceil_in  = flat_h - wall_t_lid;

    // furo com "cintura" no lugar do degrau reto — rampas de
    // ~45 graus em vez de uma prateleira horizontal, entao
    // imprime sem suporte (nada pendurado no ar sem apoio embaixo)
    taper_h   = shoulder_w;  // altura de cada rampa (~45 graus)
    landing_h = 0.6;         // trecho estreito reto — e' aqui que a
                              // borda da base bate e trava de verdade
    wide_w  = case_w + 2*fit_gap;              wide_r  = case_r + fit_gap;
    narrow_w = wide_w - 2*shoulder_w;           narrow_r = max(wide_r - shoulder_w, 1);

    z1 = 0;                    // fim da entrada larga / comeco da rampa 1
    z2 = z1 + taper_h;         // fim da rampa 1 / comeco do trecho estreito
    z3 = z2 + landing_h;       // fim do trecho estreito / comeco da rampa 2
    z4 = z3 + taper_h;         // fim da rampa 2 / volta ao normal

    difference() {
        union() {
            // corpo principal — parede lisa, uniforme
            translate([0, 0, -overlap_h])
                linear_extrude(height = overlap_h + flat_h + 0.1)
                    rrect(case_w + 2*wall_t_lid, case_r + wall_t_lid);

            translate([0, 0, flat_h - 0.1])
                hull() {
                    linear_extrude(height = 0.01)
                        rrect(case_w + 2*wall_t_lid, case_r + wall_t_lid);
                    translate([0, 0, top_round_h - 0.01 + 0.1])
                        linear_extrude(height = 0.01)
                            rrect(case_w + 2*wall_t_lid - 2*top_round_shrink,
                                  max(case_r + wall_t_lid - top_round_shrink, 1));
                }
        }

        // camara com cintura: larga -> rampa -> estreita (trava) ->
        // rampa -> larga de novo pro resto da altura. Parede fina
        // (wall_t_lid) em quase tudo, mais grossa so nos ~2.7mm da
        // cintura — sem nenhum degrau de 90 graus.
        // IMPORTANTE: cada peca sobrepõe a vizinha por 0.05mm (eps) —
        // sem isso, o CGAL as vezes falha em unir pecas que so se
        // tocam no mesmo plano exato (ja vimos esse bug antes).
        eps = 0.05;
        union() {
            translate([0, 0, -overlap_h - 0.1])
                linear_extrude(height = (z1 + eps) - (-overlap_h - 0.1))
                    rrect(wide_w, wide_r);

            hull() {
                translate([0, 0, z1 - eps])
                    linear_extrude(height = 0.01)
                        rrect(wide_w, wide_r);
                translate([0, 0, z2 + eps - 0.01])
                    linear_extrude(height = 0.01)
                        rrect(narrow_w, narrow_r);
            }

            translate([0, 0, z2 - eps])
                linear_extrude(height = landing_h + 2*eps)
                    rrect(narrow_w, narrow_r);

            hull() {
                translate([0, 0, z3 - eps])
                    linear_extrude(height = 0.01)
                        rrect(narrow_w, narrow_r);
                translate([0, 0, z4 + eps - 0.01])
                    linear_extrude(height = 0.01)
                        rrect(wide_w, wide_r);
            }

            // camara principal — parede lisa, uniforme
            translate([0, 0, z4 - eps])
                linear_extrude(height = ceil_in - (z4 - eps) + 0.2)
                    rrect(wide_w, wide_r);

            // cavidade do CAPUZ tambem oca (nao solida) — acompanha
            // o mesmo afunilamento do casco externo, so que puxada
            // pra dentro por wall_t_lid, parando um pouco antes do
            // topo pra sobrar um teto fino fechando tudo
            translate([0, 0, ceil_in - eps])
                hull() {
                    linear_extrude(height = 0.01)
                        rrect(wide_w, wide_r);
                    translate([0, 0, (top_round_h - 0.15 + eps) - 0.01])
                        linear_extrude(height = 0.01)
                            rrect(case_w + 2*wall_t_lid - 2*top_round_shrink - 2*wall_t_lid,
                                  max(case_r + wall_t_lid - top_round_shrink - wall_t_lid, 1));
                }
        }
    }
}

// ============================================================
// SELEÇÃO DE PARTE
// ============================================================
part = "both_apart";

if (part == "base") {
    base();
} else if (part == "lid") {
    lid();
} else if (part == "both_apart") {
    translate([-case_w/2 - 10, 0, 0]) base();
    translate([ case_w/2 + 12, 0, 0]) rotate([180, 0, 0]) lid();
} else if (part == "assembled") {
    base();
    translate([0, 0, func_h]) lid();
}
