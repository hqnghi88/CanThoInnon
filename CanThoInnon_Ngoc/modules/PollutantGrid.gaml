model PollutantGrid
import "GlobalVariable.gaml"
import "Vehicle.gaml"
grid pollutant_grid height: 50 width: 50 neighbors: 8 /*schedules: active_cells*/ {
	rgb color <- #black;
	bool active <- false;
	float pollution;

	reflex pollution_increase when: active {
		list<vehicle> people_on_cell <- vehicle overlapping self;
		pollution <- pollution + sum(people_on_cell accumulate (each.get_pollution()));
	}

	reflex diffusion {
		ask neighbors {
			pollution <- pollution + 0.05 * myself.pollution;
		}

		pollution <- pollution * (1 - 8 * 0.05);
	}

	reflex update {
		pollution <- pollution * decrease_coeff;
		color <- rgb(255 * pollution / 1000, 0, 0);
	}

}


