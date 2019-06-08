model Road
import "GlobalVariable.gaml"
import "Vehicle.gaml"
species road {
	int nbLanes <- 1;
	float coeff_traffic <- 1.0 update: 1 + (float(length(vehicle at_distance 10.0)) / shape.perimeter * 20 / nbLanes);

	aspect default {
		draw shape + 5 empty: false color: #darkgray-10;
	}

	aspect traffic_jam {
		if (coeff_traffic > 0.25) {
			draw shape + (coeff_traffic / 20.0) color: #red;
		}

	}

}
