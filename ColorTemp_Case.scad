// ============================================================
//  Case para o projeto ColorTemp — A color coded thermometer
//  Projeto ColorTemp Mechatronix Lab
//  Link: https://github.com/MechatronixLab/ColorTemp/tree/master
//  Case By Fabio / Embarcados
// ============================================================
//
// COMO GERAR AS PECAS — mude a variavel `part` (fim do arquivo, bloco
// "SELEÇÃO DE PARTE") pra escolher o que ver/exportar:
//   "base"        -> so a base
//   "lid"         -> so a tampa
//   "both_apart"  -> as duas pecas lado a lado, cada uma ja na
//                    orientacao de impressao certa (a tampa vem
//                    rotacionada 180° — cupula pra baixo, encaixe pra
//                    cima) — e' essa a opcao pra exportar/fatiar
//   "assembled"   -> as duas empilhadas, uma sobre a outra, so pra
//                    CONFERIR VISUALMENTE o encaixe montado — nao
//                    serve pra imprimir (nao fatiar nesse modo)
//
// RECOMENDACOES DE IMPRESSAO:
//   - 0% de preenchimento nas duas peças no fatiador — com parede tão
//     fina, qualquer infill por dentro anula a difusão da tampa e
//     pode nem fechar direito.
//   - Tampa: force 1 unico perimetro/wall-loop no fatiador (o padrão
//     costuma ser 2+) — isso que faz a parede ficar fina o bastante
//     pra difundir a luz do LED. Testado com bico de 0.4mm
//     (~0.45-0.5mm de linha real); ver wall_t_lid mais abaixo.
//   - Nenhuma das duas peças precisa de suporte — as rampas internas
//     do encaixe da tampa (lid()) e das travas (snap_*) foram
//     desenhadas a ~45° especificamente pra dispensar suporte.
//   - Montagem: a placa entra na base encaixando nos 4 pinos
//     localizadores (boss_xy/pin_d/pin_h) antes de fechar a tampa; a
//     tampa trava por pressão nos 4 nós da trava (snap_*, 1 por
//     face) — não precisa de cola nem parafuso, e dá pra abrir de
//     novo se precisar mexer na placa. Se o encaixe da tampa ficar
//     apertado/frouxo demais pro seu printer, ajustar snap_protrude/
//     snap_r/fit_gap (comentados no bloco de parametros da trava).
//
// MEDIDAS BASE (do STEP): placa 27.5x27.5mm, esp. 1.6mm; USB-C
// borda Y+ (sobe 3.85mm); botões borda X+ (atuador quase encosta
// na parede).
//
// TRAVA DA TAMPA: 4 nos rigidos (1 por face, centralizado) que
// travam no rebaixo correspondente da tampa — ver bloco de
// parametros e modulos snap_* mais abaixo.
// ============================================================

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
pin_d       = 3.3;
pin_h       = 1.8;
standoff_d  = 6.0;

// margem solida acima do recorte mais alto — dentro dela a tampa
// desliza livre ate um RESSALTO interno (ver lid()) que trava a
// profundidade, sempre no mesmo lugar
rim_margin = 2.3;   // minimo seguro: overlap_h (2.0) + 0.3mm de folga
overlap_h  = 2.0;      // profundidade de encaixe ate travar no ressalto
shoulder_w = 1.5;      // quanto o anel estreita acima do encaixe —
                        // e' nisso que a borda da base bate

// ---------- TRAVA DA TAMPA (no rigido, 1 por face, centralizado) ----------
// Um pequeno no rigido em cada uma das 4 paredes da base (sem corte,
// sem dobradica) que trava numa cavidade correspondente da tampa
// (ver snap_bump/snap_groove), no mesmo instante em que o batente
// mecanico (a "cintura" em lid()) trava a profundidade. Centralizado
// em cada face — como o no fica bem acima do recorte mais alto
// (dentro do rim_margin, ~2mm de folga), nao chega perto de botao
// nem USB-C em nenhuma das 4 faces.
//
// Quem flexiona pra deixar o no passar e' a parede FINA da tampa —
// na faixa de entrada ela e' so ~0.35mm de verdade (a cavidade ali e'
// dimensionada por fit_gap, nao por wall_t_lid). Por isso protrude/
// snap_r sao conservadores (pouca interferencia = pouca forca exigida
// da parede fina a cada abre/fecha). snap_pad reforca a tampa so na
// regiao do rebaixo, senao ele furaria essa parede fina por fora.
snap_on       = true;   // liga/desliga a trava, pra comparar facil
snap_r        = 0.55;   // raio da nervura (secao) — LIMITE: a borda
                         // interna (case_w/2+snap_protrude-2*snap_r)
                         // tem que ficar >= pocket_w/2 (~14.15mm) com
                         // folga, senao a nervura invade o bolso e
                         // trava a montagem da placa. Com os valores
                         // atuais sobra ~0.25mm — nao aumente sem
                         // recalcular.
snap_protrude = 0.35;   // quanto a nervura sai alem da face nominal
snap_clear    = 0.15;   // folga da cavidade da tampa em relacao a nervura
snap_z_off    = 0.9;    // centro da nervura, medido do topo da base
                         // (func_h) pra baixo
snap_len      = 3.0;    // comprimento da nervura ao longo da face
snap_pad_t    = 0.7;    // reforco na parede FINA da tampa, so na
                         // regiao do encaixe — sem isso o rebaixo
                         // (cavidade) fura a parede fina por fora

// 1 no por face, centralizado
snap_normals = [ [1,0], [-1,0], [0,1], [0,-1] ];

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
// TRAVA DA TAMPA — no rigido na parede da base (snap_bump) + cavidade
// correspondente na tampa (snap_groove), reforcada por fora pra nao
// furar a parede fina (snap_pad). Todos os modulos assumem normal
// alinhado a um eixo (n = [1,0], [-1,0], [0,1] ou [0,-1]) e usam
// rotate() pra reorientar uma construcao feita sempre olhando pra +X.
// ============================================================
// n = [nx, ny] — normal da face (ver snap_normals nos parametros)
module snap_bump(n) {
    rotate([0, 0, atan2(n[1], n[0])])
        translate([case_w/2 + snap_protrude - snap_r, 0, func_h - snap_z_off])
            hull()
                for (s = [-1, 1])
                    translate([0, s*(snap_len/2 - snap_r), 0])
                        sphere(r = snap_r);
}

module snap_groove(n) {
    rotate([0, 0, atan2(n[1], n[0])])
        translate([case_w/2 + snap_protrude - snap_r, 0, -snap_z_off])
            hull()
                for (s = [-1, 1])
                    translate([0, s*(snap_len/2 - snap_r), 0])
                        sphere(r = snap_r + snap_clear);
}

// reforco local na parede fina da tampa, so na regiao do encaixe —
// comeca 0.2mm PRA DENTRO da parede existente (sobreposicao, nao so
// encostando) pra garantir que o CGAL funda os dois solidos; ver nota
// sobre eps() mais abaixo no modulo lid()
module snap_pad(n) {
    eps = 0.2;
    pad_half_len = snap_len/2 + 1.0;
    // +0.3 de folga sobre o raio do rebaixo (snap_r+snap_clear) —
    // o suficiente pra cobrir a cavidade com margem sem ultrapassar
    // a borda de baixo da tampa (z=-overlap_h) nem invadir muito a
    // rampa (z=0); com +0.8 (usado antes) o reforco ficava pendurado
    // ~0.4mm abaixo do corpo principal da tampa
    pad_half_h   = snap_r + snap_clear + 0.3;
    rotate([0, 0, atan2(n[1], n[0])])
        translate([case_w/2 + wall_t_lid - eps, -pad_half_len, -snap_z_off - pad_half_h])
            cube([snap_pad_t + eps, 2*pad_half_len, 2*pad_half_h]);
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
            if (snap_on)
                for (n = snap_normals) snap_bump(n);
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

            // reforco local pra caber o rebaixo da trava sem furar
            // a parede fina (ver bloco de parametros da trava)
            if (snap_on)
                for (n = snap_normals) snap_pad(n);
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

            if (snap_on)
                for (n = snap_normals) snap_groove(n);
        }
    }
}

// ============================================================
// SELEÇÃO DE PARTE
// ============================================================
part = "assembled";

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
