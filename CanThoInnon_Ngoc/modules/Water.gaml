model Water

species water { 
	float wlevel <- -14.0;
	int incr <- 1;
	geometry shape <- box(world.shape.width, world.shape.height, 1);

	reflex innon {
		wlevel <- wlevel + incr * 0.01;
		if (wlevel > -8) {
			incr <- -1;
		}

		if (wlevel < -14.0) {
			incr <- 1;
		}

		location <- {world.shape.width / 2, world.shape.height / 2, wlevel};
	}

	aspect default {
		draw shape texture:("../images/water2.gif") color: #black at: location;
		
	}

}

