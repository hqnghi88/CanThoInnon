model Building
import "Moveable.gaml"
import "GlobalVariable.gaml"

species building parent: moveable {
	float depth;
	string osm_name;
	file texture;
	float get_weight {
		return (shape.area / 10000) * coeff_building;
	}

	aspect default {
		draw shape depth: depth color: #gray texture: [roof_texture.path, texture.path];
		if (#zoom > 6 and osm_name index_of "osm_agent" != 0) {
			draw osm_name anchor: #center font: regular color: #yellow at: {location.x, location.y, (depth + 1)} perspective: false;
		}

	}

}
