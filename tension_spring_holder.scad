//Phone Holder

include <MCAD/boxes.scad>
include <../../metric_fasteners/nuts_and_bolts.scad>

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

/*[spring dimensions]*/
springD = 3;


/*[spoke dimensions]*/
spokeDia = 2;

/*[Hidden]*/
mainDim = [mainX, mainY, mainZ];
fingerDim = [mainX, fingerY+mainY+lipY, fingerZ];
lipDim = [mainX*.75, lipY, lipZ];
springLen = mainZ*1.01; 

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
  difference() {
    body();

    //add the spring channels
    for(i = [-1, 1]) {
      translate([mainX/100*18*i, -mainY/2, 0])
        springChannel();
      
      //add teh spoke holes 
      translate([i*(mainX/3-spokeDia/2), mainY/10, 0])
        rotate([0, 0, 90*i])
        spoke();
    }
      
  }
}

assemble();
