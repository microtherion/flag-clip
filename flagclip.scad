/*
 * Flagclip - Flag attachment carabine
 *
 * Copyright (C) 2022-23 Matthias Neeracher <microtherion@gmail.com>
 */

// Diameter of flagpole wire
wire_dia        = 3.9;          // [1.0:0.05:7.0]

/* [Other Parameters - Tune if Needed] */
// Thickness (Z)
thickness       = 4.0;          // [3.0:0.25:8.0]
// Width of outer walls
wall            = 4.0;          // [2.0:0.25:6.0]
// Gaps for carabine and spring openings
gap             = 1.0;          // [0.5:0.25:2.0]

/* [Spring Parameters - Tune if Needed] */
// Spring Center Radius
spring_center   = 3.0;          // [2.0:0.5:10.0]
// Gap Between Inner and Outer Rings
spring_gap      = 3.0;          // [1.0:0.5:5.0]

/* [Carabine Parameters - Tune if Needed] */
// Aperture Angle of Carabine Loop
cara_aperture   = 45.0;         // [30:5:90]
// Length of Carabine Arm
cara_arm        = 15.0;         // [10:5:50]

/* [Clip Parameters - Tune if Needed] */
// Width of Inner Gap for Clip
clip_aper       = 2.5;          // [1.0:.5:10]
// Width of Clip at Bottom of Opening
clip_base       = 12.0;         // [10.0:50.0]
// Length of Clip Arm
clip_arm        = 18.0;         // [15.0:50.0]
// Arc of Wire Holder
clip_arc        = 290;          // [190.0:10:330]
// Width of Wire Holder Walls
clip_wall       = 2.0;          // [1.0:0.25:4.0]
// Clearance of Gap from Edge of Spring
clip_clear      = 4.0;          // [1.0:1.0:10.0]
// Vertical Displacement of Clip Gap
clip_lever      = 4.0;          // [0.0:0.25:6.0]

function intersect_circle(p0, v, r) =
    let (num = sqrt((r^2-p0[0]^2)*v[1]^2+2*p0[0]*p0[1]*v[0]*v[1]+(r^2-p0[1]^2)*v[0]^2)-p0[1]*v[1]-p0[0]*v[0],
         l = num/(v[1]^2+v[0]^2)) p0+l*v;

function intersect_lines(p0, v, q0, w) =
    let (l = (-q0[0]*w[1]+p0[0]*w[1]+(q0[1]-p0[1])*w[0])/(v[1]*w[0]-v[0]*w[1])) p0+l*v;

module flagclip(wire_dia=wire_dia, thickness=thickness, wall=wall,
                spring_center=spring_center, spring_gap=spring_gap,
                cara_aperture=cara_aperture, cara_arm=cara_arm,
                gap=gap,
                clip_aper=clip_aper, clip_base=clip_base, clip_arm=clip_arm,
                clip_arc=clip_arc, clip_wall=clip_wall, clip_clear=clip_clear,
                clip_lever=clip_lever)
{
    spring_inner_in_r  = spring_center;
    spring_inner_out_r = spring_inner_in_r + wall;
    spring_outer_in_r  = spring_inner_out_r + spring_gap;
    spring_outer_out_r = spring_outer_in_r + wall;

    cara_ratio_r       = [sin(0.5*cara_aperture), cos(0.5*cara_aperture)];
    cara_ratio_out_r   = [cos(0.5*cara_aperture), -sin(0.5*cara_aperture)];
    cara_inner_bot_r   = [0.5*spring_gap, spring_outer_in_r*cos(asin(0.5*spring_gap/spring_outer_in_r))];
    cara_inner_top_r   = cara_inner_bot_r+cara_arm*cara_ratio_r;
    cara_outer_top_r   = cara_inner_top_r+wall*cara_ratio_out_r;
    cara_outer_top_rp  = cara_inner_top_r+(wall+1)*cara_ratio_out_r;
    cara_outer_bot_r   = cara_outer_top_r-(cara_arm-0.5*wall)*cara_ratio_r;
    cara_ratio_l       = [-sin(0.5*cara_aperture), cos(0.5*cara_aperture)];
    cara_ratio_out_l   = [-cos(0.5*cara_aperture), -sin(0.5*cara_aperture)];
    cara_inner_bot_l   = [-cara_inner_bot_r[0], cara_inner_bot_r[1]];
    cara_inner_top_l   = cara_inner_bot_l+cara_arm*cara_ratio_l;
    cara_outer_top_l   = cara_inner_top_l+wall*cara_ratio_out_l;
    cara_outer_top_lp  = cara_inner_top_l+(wall+1)*cara_ratio_out_l;
    cara_outer_bot_l   = cara_outer_top_l-(cara_arm-0.5*wall)*cara_ratio_l;
    cara_inner_gap_l   = cara_inner_bot_l+(cara_arm-gap)*cara_ratio_l;
    cara_outer_gap_l   = cara_inner_gap_l+wall*cara_ratio_out_l;
    cara_loop_center   = [0,cara_inner_top_r[1]];
    cara_loop_in_r     = cara_inner_top_r[0];
    cara_loop_out_r    = cara_loop_in_r+wall;

    clip_half_aperture = asin(0.5*(clip_base-clip_aper)/clip_arm);
    clip_ratio_r       = [sin(clip_half_aperture), -cos(clip_half_aperture)];
    clip_ratio_out_r   = [-clip_ratio_r[1], clip_ratio_r[0]];
    clip_inner_in_r    = [0.5*clip_aper, -spring_inner_in_r*cos(asin(0.5*clip_aper/spring_inner_in_r))];
    clip_inner_in_l    = [-clip_inner_in_r[0], clip_inner_in_r[1]];
    clip_inner_out_r   = [0.5*clip_aper, -spring_inner_out_r*cos(asin(0.5*clip_aper/spring_inner_out_r))];
    clip_inner_out_l   = [-clip_inner_out_r[0], clip_inner_out_r[1]];
    clip_bot_in_r      = clip_inner_out_r+clip_arm*clip_ratio_r;
    clip_bot_out_r     = clip_bot_in_r+wall*clip_ratio_out_r;
    clip_inner_r       = clip_bot_out_r-(clip_arm+0.5*wall)*clip_ratio_r;
    clip_inner_inter_r = intersect_circle(clip_inner_r, clip_ratio_r, spring_inner_out_r);
    clip_ratio_l       = [-clip_ratio_r[0], clip_ratio_r[1]];
    clip_ratio_out_l   = [clip_ratio_l[1], -clip_ratio_l[0]];
    clip_bot_in_l      = clip_inner_out_l+clip_arm*clip_ratio_l;
    clip_bot_out_l     = clip_bot_in_l+wall*clip_ratio_out_l;
    clip_inner_l       = clip_bot_out_l-(clip_arm+0.5*wall)*clip_ratio_l;
    clip_outer_inter_l = intersect_circle(clip_inner_l, clip_ratio_l, spring_outer_out_r);
    clip_inner_inter_l = intersect_circle(clip_inner_l, clip_ratio_l, spring_inner_out_r);
    clip_outer_gap_t   = clip_outer_inter_l+clip_clear*clip_ratio_l;
    clip_outer_gap_b   = clip_outer_gap_t+gap*clip_ratio_l;
    clip_inner_gap_t   = clip_outer_gap_t-wall*clip_ratio_out_l-clip_lever*clip_ratio_l;
    clip_inner_gap_b   = clip_inner_gap_t+gap*clip_ratio_l;
    wire_center        = [0, clip_bot_in_r[1]+0.5*wire_dia];
    clip_angle         = 180-0.5*clip_arc;
    wire_ratio         = [sin(clip_angle), cos(clip_angle)];
    wire_out_r         = clip_wall*[wire_ratio[1], -wire_ratio[0]];
    clip_wire_inter_r  = intersect_lines(clip_bot_in_r, clip_ratio_r, wire_center, wire_ratio);
    clip_wire_inter_l  = [-clip_wire_inter_r[0], clip_wire_inter_r[1]];
    wire_out_l         = clip_wall*[-wire_ratio[1], -wire_ratio[0]];

    linear_extrude(height=thickness) {
        /* Spring */
        difference() {
            union() {
                difference() {
                    circle(r = spring_outer_out_r);
                    circle(r = spring_outer_in_r);
                }
                circle(r = spring_inner_out_r);
                translate([-spring_outer_in_r-1,-0.5*wall,0])
                    square(size=[2*spring_outer_in_r+2, wall]);
            }
            circle(r = spring_inner_in_r);
            /* Opening for Carabine */
            polygon(points=[cara_inner_bot_r, cara_inner_top_r, cara_inner_top_l, cara_inner_bot_l]);
            /* Opening for Clip */
            polygon(points=[clip_inner_in_l, clip_inner_out_l, clip_bot_in_l, clip_bot_in_r, clip_inner_out_r, clip_inner_in_r]);
            polygon(points=[clip_inner_gap_b, clip_inner_gap_t, clip_outer_gap_t, clip_outer_gap_b]);
        }
        /* Carabine */
        difference() {
            translate(cara_loop_center) circle(r = cara_loop_out_r);
            translate(cara_loop_center) circle(r = cara_loop_in_r);
            polygon(points=[cara_outer_top_rp, cara_inner_top_r, cara_loop_center, cara_inner_top_l, cara_outer_top_lp, [cara_outer_top_l[0], 0], [cara_outer_top_r[0], 0]]);
        }
        polygon(points=[cara_outer_bot_r, cara_outer_top_r, cara_inner_top_r, cara_inner_bot_r]);
        polygon(points=[cara_outer_bot_l, cara_outer_gap_l, cara_inner_gap_l, cara_inner_bot_l]);
        /* Clip */
        difference() {
            translate(clip_bot_in_r) circle(r=wall);
            translate([clip_bot_in_r[0]-wall, clip_bot_in_r[1]-wall]) square(size=[wall, 2*wall]);
        }
        polygon(points=[clip_bot_in_r, clip_bot_out_r, clip_inner_inter_r, clip_inner_out_r]);
        difference() {
            translate(clip_bot_in_l) circle(r=wall);
            translate([clip_bot_in_l[0], clip_bot_in_r[1]-wall]) square(size=[wall, 2*wall]);
        }
        difference() {
            polygon(points=[clip_bot_in_l, clip_inner_out_l, clip_inner_inter_l, clip_bot_out_l]);
            polygon(points=[clip_inner_gap_b, clip_inner_gap_t, clip_outer_gap_t, clip_outer_gap_b]);
        }
        translate([clip_bot_in_l[0], clip_bot_in_l[1]-wall]) square(size=[clip_base, wall]);
        difference() {
            union() {
                translate(wire_center) circle(r=0.5*wire_dia+clip_wall);
                polygon(points=[wire_center, wire_center+wire_out_r, clip_wire_inter_r+wire_out_r, clip_wire_inter_r]);
                polygon(points=[wire_center, clip_wire_inter_l, clip_wire_inter_l+wire_out_l, wire_center+wire_out_l]);
            }
            translate(wire_center) circle(r=0.5*wire_dia);
            polygon(points=[wire_center, clip_wire_inter_r, clip_wire_inter_l]);
            translate(clip_wire_inter_l) square([clip_base, wall]);
        }
    }
}

flagclip();
