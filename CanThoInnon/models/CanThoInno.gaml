/**
* Name: GeoTIFF file to Grid of Cells 
* Author:  Patrick Taillandier
* Description: Model which shows how to create a grid of cells by using a GeoTIFF File. 
* Tags:  load_file, tif, gis, grid
*/
model geotiffimport

global {
//definiton of the file to import
	file grid_data <- file('../includes/canthodem.tif');
	file road_shp <- file("../includes/roads2.shp");
	file building_shp <- file("../includes/building.shp");
	//computation of the environment size from the geotiff file
	geometry shape <- envelope(grid_data);
	graph the_graph;
	float max_value;
	float min_value;

	init {
		max_value <- cell max_of (each.grid_value);
		min_value <- cell min_of (each.grid_value);
		write max_value;
		write min_value;
		ask cell {
			int val <- 255 - int(255 * (1 - (grid_value - min_value) / (max_value - min_value)));
			color <- rgb(val, val, val);
		}

		create road from: road_shp;
		the_graph <- as_edge_graph(list(road));
		create building from: building_shp{
			 depth <-	(rnd(100)/100) *(rnd(100)/100*shape.width) +10;			
		}
		create people number: 1000 {	
				location <- any_location_in(any(road));
				target <-  any_location_in(any(road));
		}

	}

}

species people skills: [moving] {
	float size <- 1.0+rnd(2);
	float sp <- 20+rnd(30.0); 
	geometry shape <- circle(size);
	float range <- size * 2;
	int repulsion_strength min: 1 <- 5;
	point target;

	reflex ss {
		do goto target: target on: the_graph speed: sp;
		if (target != nil and location distance_to target <= sp) {
			target <- any_location_in(one_of(road));
		}

	}

	aspect default {
		draw shape color: #yellow;
	}

}

species road {

	aspect default {
		draw shape color: #gray;
	}

}

species building {

	float depth;
	aspect default {
		draw shape depth:depth color: #red;
	}

}
//definition of the grid from the geotiff file: the width and height of the grid are directly read from the asc file. The values of the asc file are stored in the grid_value attribute of the cells.
grid cell file: grid_data;

experiment show_example type: gui {
	output {
		display test type: opengl {
//			grid cell elevation: grid_value triangulation:true;
			grid cell refresh:false;
			species road refresh:false;
			species building refresh:false;
			species people;
		} 
	}

}
