//Phone Holder

include <MCAD/boxes.scad>
include <../metric_fasteners/nuts_and_bolts.scad>

/*[body dimensions]*/
mainX = 23;
mainY = 8;
mainZ = 30;

fingerY = 5;
fingerZ = 5;

lipY = 3;
lipZ = 3;
lipCorner = 1;

corner = 1;
quality = 36;

/*[spring and bolt dimensions]*/
boltDia = 3;
// Outer spring diameter
springDia = 5.5;
springLen = 15;


/*[spoke dimensions]*/
spokeDia = 2;

/*[Hidden]*/
mainDim = [mainX, mainY, mainZ];
fingerDim = [mainX, fingerY+mainY+lipY, fingerZ];
lipDim = [mainX*.75, lipY, lipZ];
//springLen = mainZ*1.01; 

/*
module springChannel(cornerDia = 1.5) {
  cornerRad = cornerDia/2;
  dia = .8;
  localSpringD = springD * 1.08;

  //move the cut for the spring channels up fingerZ amount
  translate([0, 0, fingerZ]) 
    roundedBox([localSpringD, localSpringD*2, springLen], cornerRad, sidesonly = 1, $fn = quality);

  //loop twice to create the beveled corners
  for(i = [-1, 1]) {
    translate([localSpringD/2*-i-cornerRad*i, cornerRad, fingerZ]) 
      difference() {
        translate([cornerRad*i, -cornerRad, 0])
          cube([cornerRad*2, cornerRad*2, springLen], center = true);
        cylinder(r = cornerRad, center = true, h = springLen, $fn = quality);
      }

    //add the bolt holes 
    translate([0, -2, -mainZ/2+fingerZ*2])
      rotate([-90, 0, 0])
      #bolt(size = metric_fastener[2], threadType = "none", length = mainY, 
        quality = 36, tolerance = .2, head = "socketBlank");
  }
}
*/

module body() {
  union() {
    roundedBox(mainDim, corner, sidesonly = 1, $fn = quality);
    translate([0, (fingerDim[1]-mainY)/2, -mainZ/2+fingerDim[2]/2])
      roundedBox(fingerDim, corner, sidesonly = 1, $fn = quality);
        //translate([0, fingerY+mainY/2-lipY/2, -mainZ/2+fingerZ])
        translate([0, fingerDim[1]-mainY/2-lipY/2, -mainZ/2+fingerZ])
      roundedBox(lipDim, lipCorner, $fn = quality);
  }
}

module spoke() {
  spokeLen = mainZ * 1.01;
  translate([0, 0, -spokeLen/2])
  union() {
    cylinder(r = spokeDia/2, h = spokeLen, $fn = quality);
    translate([0, spokeDia/2, spokeDia/2])
      cube([spokeDia, spokeDia*2, spokeDia], center = true);
  }
}


module assemble() {
  tolerance = 0.3;
  // socket head thickness taken from the metric_fastener library
  socketHeadThick = metric_fastener[boltDia][4];
  


  // set the head diameter
  socketHeadDia = metric_fastener[boltDia][4]+tolerance;
  //localSpringDia = springDia*1.05;
  // choose the larger of the two diameters for the spring channel
  localSpringDia = springDia < socketHeadDia ? socketHeadDia : springDia;
  difference() {
    body();

    //add the spring channels with bolts
    for(i = [-1, 1]) {
      // add the bolt channels
      translate([i*(mainX/4), 0, socketHeadThick])
        rotate([180, 0, 0])
        bolt(metric_fastener[boltDia], threadType = "none", length = mainZ, v = true, tolerance = tolerance, center = true, list = true, head = "socketBlank");
      // add a space for the spring
      translate([i*(mainX/4), 0, -mainZ/2+springLen/2+socketHeadThick/2])
        cylinder(r = localSpringDia/2, h = springLen+socketHeadThick+.001, center = true, $fn = quality);

      // add a bolt/nut hole for mounting
      translate([0, 0, 0])
        rotate([-90, 30, 0])
        //#nutHole(size = metric_fastener[4], h = mainY*1.1, tollerance = 0.4, center = true);
        #bolt(size = metric_fastener[4], head = "socket", threadType = "none", tollerance = 0.4, length = mainY, center = true);
    }
      
  }
}

assemble();
list_types(metric_fastener, boltDia);
